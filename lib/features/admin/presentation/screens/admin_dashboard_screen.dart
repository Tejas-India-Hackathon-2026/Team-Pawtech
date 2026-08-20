import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_app_bar.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../../../../shared/widgets/tag_badge.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PashuAppBar(title: 'Admin Control Center'),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primaryDark,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: '🛡️ Seller Verification'),
              Tab(text: '🚨 AI Content Moderation'),
              Tab(text: '🏥 NGO Management'),
              Tab(text: '📋 Referral Requests'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Seller Verification Management Tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PashuCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Seller: Rajesh Sharma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              TagBadge(text: 'PENDING VERIFICATION', variant: TagVariant.warning),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text('ID Type: Aadhaar Card (XXXX-XXXX-9012)', style: TextStyle(fontSize: 12)),
                          const Text('Document: aadhaar_scan_rajesh.pdf', style: TextStyle(fontSize: 11, color: AppColors.primaryDark)),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.emergencyRed)),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification Application Rejected.')));
                                },
                                child: const Text('Reject', style: TextStyle(color: AppColors.emergencyRed)),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                icon: const Icon(Icons.verified, size: 16),
                                label: const Text('Grant "✓ Verified Seller" Badge'),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Granted "✓ Verified Seller" Badge to user.')));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 2. AI Content Moderation Queue Tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PashuCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Post #POST-991', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              TagBadge(text: 'FLAGGED FOR REVIEW (Risk: 0.85)', variant: TagVariant.danger),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Author: User_901\nContent: "Selling exotic illegal parrot at cheap price, send money to UPI..."',
                            style: TextStyle(fontSize: 12, height: 1.4),
                          ),
                          const SizedBox(height: 4),
                          const Text('AI Flag Reason: Unsafe / Illegal animal trade, Suspicious financial request', style: TextStyle(fontSize: 10, color: AppColors.emergencyRed, fontWeight: FontWeight.bold)),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post restored.')));
                                },
                                child: const Text('Restore Post'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyRed, foregroundColor: Colors.white),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post removed & User suspended.')));
                                },
                                child: const Text('Remove Post & Suspend User'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 3. NGO Management Tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PashuCard(
                      child: ListTile(
                        leading: const Icon(Icons.shield, color: AppColors.primary, size: 32),
                        title: const Text('Wildlife SOS India', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Category: Wildlife Rescue • Status: Verified Partner'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.primary),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),

                // 4. Referral Requests Tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PashuCard(
                      child: ListTile(
                        leading: const Icon(Icons.assignment, color: AppColors.primary, size: 32),
                        title: const Text('Ref #REF-10192: Injured Pigeon', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Assigned: Wildlife SOS • Status: In Progress'),
                        trailing: const TagBadge(text: 'IN PROGRESS', variant: TagVariant.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
