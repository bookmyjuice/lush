import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:duration_button/duration_button.dart';

class Payments extends StatefulWidget {
  const Payments({super.key, required this.amount, required this.description});

  final int amount;
  final String description;
  static const routeName = '/paymentRoute';

  @override
  PaymentsState createState() => PaymentsState();
}

class PaymentsState extends State<Payments> {
  // static const platform = MethodChannel("razorpay_flutter");

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _razorpay.on(
        Razorpay.INCOMPATIBLE_PLUGIN.toString(), _handlerIncompatiblePlugin);
    // _razorpay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Razorpay Sample App'),
        // ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              Text("Pay Rs. ${widget.amount}"),
              DurationButton(
                  onComplete: openCheckout,
                  duration: const Duration(milliseconds: 10),
                  onPressed: openCheckout,
                  child: const Text("Checkout Now!",style: TextStyle(color: Colors.white),)),
              const SizedBox(height: 55,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  FloatingActionButton.small(
                      onPressed: () {
                        navService.popUntil("/home2");
                      },
                      child: const Icon(Icons.arrow_back)),
                  const Text("Go Back"),

                ],
              )
              // ElevatedButton(onPressed: openCheckout, child: const Text(".."))
            ])),
      ),
    );
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_5O37uNi7fzqqXI',
      'amount': widget.amount*100,
      'name': 'Lush Juices',
      'description':
          widget.description,
      'prefill': {'contact': '7042396726', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };
    _razorpay.open(options);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: "SUCCESS: ${response.paymentId!}",
        toastLength: Toast.LENGTH_SHORT);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: ${response.code} - ${response.message!}",
        toastLength: Toast.LENGTH_SHORT);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: ${response.walletName!}",
        toastLength: Toast.LENGTH_SHORT);
  }

  void _handlerIncompatiblePlugin(MissingPluginException r) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: ${r.message}", toastLength: Toast.LENGTH_SHORT);
  }
}
