import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lush/services/invoice_service.dart';
import 'package:url_launcher/url_launcher.dart';

class InvoiceViewScreen extends StatefulWidget {
  static const routeName = '/invoices';

  const InvoiceViewScreen({super.key});

  @override
  State<InvoiceViewScreen> createState() => _InvoiceViewScreenState();
}

class _InvoiceViewScreenState extends State<InvoiceViewScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  List<Map<String, dynamic>> _invoices = [];
  bool _isLoading = true;
  String? _error;
  bool _showLocalInvoices = false;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final invoices = _showLocalInvoices
          ? await _invoiceService.getLocalInvoiceHistory()
          : await _invoiceService.getMyInvoices();
      setState(() {
        _invoices = invoices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleInvoiceSource() {
    setState(() {
      _showLocalInvoices = !_showLocalInvoices;
    });
    _loadInvoices();
  }

  Future<void> _downloadPdf(String invoiceId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final pdfUrl = await _invoiceService.getInvoicePdfUrl(invoiceId);
      Navigator.pop(context); // Close loading dialog

      if (pdfUrl != null && pdfUrl.isNotEmpty) {
        final uri = Uri.parse(pdfUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showError('Could not open PDF');
        }
      } else {
        _showError('PDF URL not available');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showError('Failed to download PDF: $e');
    }
  }

  Future<void> _sendEmail(String invoiceId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await _invoiceService.sendInvoiceEmail(invoiceId);
      Navigator.pop(context); // Close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice sent to your email successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError('Failed to send email');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showError('Failed to send email: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp == null) return 'N/A';
      final date = timestamp is int
          ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
          : DateTime.parse(timestamp.toString());
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatCurrency(dynamic amount) {
    try {
      if (amount == null) return '\$0.00';
      final value =
          amount is int ? amount / 100 : double.parse(amount.toString());
      return '\$${value.toStringAsFixed(2)}';
    } catch (e) {
      return '\$0.00';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: Icon(_showLocalInvoices ? Icons.cloud : Icons.storage),
            tooltip: _showLocalInvoices
                ? 'Show Chargebee Invoices'
                : 'Show Local Invoices',
            onPressed: _toggleInvoiceSource,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadInvoices,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _invoices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'No invoices found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadInvoices,
                      child: ListView.builder(
                        itemCount: _invoices.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final invoice = _invoices[index];
                          return _buildInvoiceCard(invoice);
                        },
                      ),
                    ),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
    final invoiceId = invoice['id'] ?? 'Unknown';
    final status = invoice['status']?.toString().toUpperCase() ?? 'UNKNOWN';
    final total = _formatCurrency(invoice['total']);
    final amountDue = _formatCurrency(invoice['amountDue'] ?? 0);
    final amountPaid = _formatCurrency(invoice['amountPaid'] ?? 0);
    final date = _formatDate(invoice['date']);
    final dueDate = _formatDate(invoice['dueDate']);

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'PAID':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'PENDING':
      case 'POSTED':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'PAYMENT_DUE':
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        break;
      case 'NOT_PAID':
        statusColor = Colors.red;
        statusIcon = Icons.money_off;
        break;
      case 'VOIDED':
        statusColor = Colors.grey;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice #${invoiceId.substring(0, invoiceId.length as int > 12 ? 12 : invoiceId.length)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Date: $date',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (dueDate != 'N/A')
                        Text(
                          'Due: $dueDate',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      total,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Amount Due',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      amountDue,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            amountDue == '\$0.00' ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!_showLocalInvoices) ...[
                  OutlinedButton.icon(
                    onPressed: () => _sendEmail(invoiceId.toString()),
                    icon: const Icon(Icons.email, size: 18),
                    label: const Text('Email'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _downloadPdf(invoiceId.toString()),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('PDF'),
                  ),
                ] else ...[
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _InvoiceDetailsDialog(
                          invoiceService: _invoiceService,
                          invoiceId: invoiceId.toString(),
                          isLocal: true,
                        ),
                      );
                    },
                    child: const Text('View Details'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceDetailsDialog extends StatelessWidget {
  final InvoiceService invoiceService;
  final String invoiceId;
  final bool isLocal;

  const _InvoiceDetailsDialog({
    required this.invoiceService,
    required this.invoiceId,
    required this.isLocal,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: isLocal
          ? invoiceService.getLocalInvoiceDetails(invoiceId)
          : invoiceService.getInvoiceDetails(invoiceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AlertDialog(
            content: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load invoice details: ${snapshot.error}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        }

        final invoice = snapshot.data!;

        return AlertDialog(
          title: Text('Invoice #${invoiceId.substring(0, 12)}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Status', invoice['status'].toString()),
                _buildDetailRow('Total',
                    '\$${(invoice['total'] / 100).toStringAsFixed(2)}'),
                _buildDetailRow('Amount Due',
                    '\$${(invoice['amountDue'] / 100).toStringAsFixed(2)}'),
                _buildDetailRow('Amount Paid',
                    '\$${(invoice['amountPaid'] / 100).toStringAsFixed(2)}'),
                if (invoice['customerId'] != null)
                  _buildDetailRow(
                      'Customer ID', invoice['customerId'].toString()),
                if (invoice['date'] != null)
                  _buildDetailRow(
                    'Date',
                    DateFormat('MMM dd, yyyy').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          (invoice['date'] as int) * 1000),
                    ),
                  ),
                if (invoice['dueDate'] != null)
                  _buildDetailRow(
                    'Due Date',
                    DateFormat('MMM dd, yyyy').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          (invoice['dueDate'] as int) * 1000),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
