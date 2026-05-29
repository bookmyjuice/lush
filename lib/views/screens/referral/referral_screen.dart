import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../bloc/ReferralBloc/referral_bloc.dart';
import '../../../bloc/ReferralBloc/referral_event.dart';
import '../../../bloc/ReferralBloc/referral_state.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(key: const Key('referral_appbar'), title: const Text('Refer & Earn'), centerTitle: true),
      body: BlocBuilder<ReferralBloc, ReferralState>(
        builder: (context, state) {
          if (state is ReferralLoading) return const Center(key: Key('referral_loading'), child: CircularProgressIndicator());
          if (state is ReferralLoaded) return _buildLoadedContent(context, state);
          if (state is ReferralError) return _buildErrorContent(context, state);
          return const SizedBox.shrink();
        },),
    );
  }
  Widget _buildLoadedContent(BuildContext context, ReferralLoaded state) {
    final info = state.info;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Your Referral Code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(info.referralCode,
                    key: const Key('referral_code_text'),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    ElevatedButton.icon(
                      key: const Key('copy_code_button'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: info.referralCode));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Referral code copied!')));
                      },
                      icon: const Icon(Icons.copy), label: const Text('Copy Code'),),
                    ElevatedButton.icon(
                      key: const Key('share_button'),
                      onPressed: () {
                        Share.share('Use my referral code ${info.referralCode} to sign up and get rewards!');
                      },
                      icon: const Icon(Icons.share), label: const Text('Share'),),
                  ],),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(key: const Key('referral_stats_card'),
            elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(padding: const EdgeInsets.all(20.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _buildStatColumn('Friends Joined', '${info.referralCount}', Icons.people),
                _buildStatColumn('Total Earned', '₹${info.totalRewardAmount.toStringAsFixed(2)}', Icons.monetization_on),
              ],),),
          ),
          const SizedBox(height: 16),
          Card(key: const Key('how_it_works_card'), elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('How It Works', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),),
              Divider(),
              ListTile(leading: CircleAvatar(child: Text('1')), title: Text('Share your referral code'), subtitle: Text('Send your unique code to friends and family')),
              ListTile(leading: CircleAvatar(child: Text('2')), title: Text('They sign up'), subtitle: Text('Your friends use your code when creating an account')),
              ListTile(leading: CircleAvatar(child: Text('3')), title: Text('They get a discount'), subtitle: Text('Your friends enjoy a discount on their first order')),
              ListTile(leading: CircleAvatar(child: Text('4')), title: Text('You earn rewards'), subtitle: Text('You earn credit for every friend who joins')),
            ],),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(children: [
      Icon(icon, size: 32, color: Colors.green),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
    ],);
  }

  Widget _buildErrorContent(BuildContext context, ReferralError state) {
    return Center(key: const Key('referral_error'),
      child: Padding(padding: const EdgeInsets.all(24.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(state.message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(key: const Key('referral_retry_button'),
            onPressed: () { context.read<ReferralBloc>().add(const LoadReferralInfo()); },
            child: const Text('Retry'),),
        ],),),);
  }
}
