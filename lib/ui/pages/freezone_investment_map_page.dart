import 'package:flutter/material.dart';
import '../theme.dart';

class FreezoneInvestmentMapPage extends StatelessWidget {
  const FreezoneInvestmentMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        title: const Text(
          'UAE Free Zone Investment Map',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.purple, AppColors.purple.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Anchor Tenant & Revenue Proxies',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Strategic analysis of UAE\'s top free zones, their revenue models, and anchor tenants. Essential intelligence for investors and business executives.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Strategic Alignment Table
            _buildSectionHeader(
              'Strategic Alignment Overview',
              Icons.table_chart,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildAlignmentTable(),
            const SizedBox(height: 28),

            // Key Strategic Takeaways
            _buildSectionHeader(
              'Key Strategic Takeaways',
              Icons.insights,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildTakeaway(
              '1. Dual-Zone Competitive Advantage',
              'The DIFC-JAFZA integration framework represents the UAE\'s most powerful strategic alignment. Global enterprises can seamlessly connect sophisticated financial governance (DIFC\'s common law framework) with rapid logistical deployment (JAFZA\'s world-class infrastructure). This enables complex capital structures to support operational speed, maximizing both profit retention and efficiency.',
              Icons.sync_alt,
              Colors.purple,
            ),
            _buildTakeaway(
              '2. Public Listing = Transparent Revenue Proxy',
              'ADGM provides the highest-quality revenue proxy through its ability to facilitate public listings. Companies like Borouge, Americana, and Anghami demonstrate verifiable market capitalization and financial health, distinguishing them from private FZEs. This institutional credibility and liquidity mechanism attracts high-value corporations seeking transparent valuations.',
              Icons.trending_up,
              Colors.green,
            ),
            _buildTakeaway(
              '3. High-Volume vs. High-Margin Strategies',
              'AFZ thrives with 20,000+ companies generating aggregate volume revenue. Conversely, SHAMS attracts capital-light service firms (media, IT, consultancy) achieving exceptional profit margins with minimal overhead. A \$50M software firm in SHAMS may yield higher net profit than a \$500M commodity trader in AFZ due to lower operational costs and simplified compliance.',
              Icons.analytics,
              Colors.blue,
            ),
            const SizedBox(height: 28),

            // Free Zone Clusters
            _buildSectionHeader(
              'Free Zone Clusters & Anchor Tenants',
              Icons.business,
              Colors.teal,
            ),
            const SizedBox(height: 12),

            _buildClusterCard(
              'Global Finance',
              'DIFC, ADGM',
              'G-SIB Concentration / AUM',
              [
                '27 of 29 Global Systemically Important Banks (G-SIBs)',
                'State Street Global Advisors',
                'Investec Bank',
                'Blue Owl (alternative asset manager)',
                'Tudor Capital (hedge fund)',
                'Hamilton Lane (private markets)',
              ],
              Colors.indigo,
              Icons.account_balance,
            ),
            _buildClusterCard(
              'Heavy Trade & Logistics',
              'JAFZA, Dubai South',
              'Fortune 500 Status / CapEx',
              [
                '100+ Fortune 500 companies',
                'Nestlé (food & water manufacturing)',
                'PepsiCo (regional distribution)',
                'Unilever (manufacturing & distribution)',
                'Maersk (global logistics)',
                'DHL, Emirates SkyCargo, FedEx (express transport)',
              ],
              Colors.blue,
              Icons.local_shipping,
            ),
            _buildClusterCard(
              'Commodities & High-Volume Trading',
              'DMCC',
              'Trading Volume / Transaction Value',
              [
                '25,000+ businesses',
                'Trafigura (commodity trading)',
                'Socar Trading (energy)',
                'Litasco (oil trading)',
                'EDF EN Middle East (energy)',
                'DGCX (Dubai Gold & Commodities Exchange)',
              ],
              Colors.amber,
              Icons.show_chart,
            ),
            _buildClusterCard(
              'Industrial & Heavy CapEx',
              'KEZAD, HFZA',
              'Long-term CapEx / 50-year Leases',
              [
                'Emirates Global Aluminium (EGA)',
                'Kings Aluminium Industries (AED 750M investment)',
                'Zora Project Dana Gas',
                'Crystal Petroleum',
                'National Oil Storage Company',
              ],
              Colors.deepOrange,
              Icons.factory,
            ),
            _buildClusterCard(
              'Digital & High-Margin Services',
              'DIC, Masdar, SHAMS',
              'Regional Licensing / R&D Capital',
              [
                'Microsoft (cloud & software)',
                'Google (digital advertising)',
                'Cisco (networking)',
                'Oracle (enterprise software)',
                'Siemens Energy (renewable solutions)',
                'G42 Healthcare (AI health tech)',
              ],
              Colors.purple,
              Icons.computer,
            ),
            _buildClusterCard(
              'Regional Manufacturing & FMCG',
              'RAKEZ',
              'Market Penetration / Volume Production',
              [
                'RAK Ceramics (global leader)',
                'Coca Cola (bottling & distribution)',
                'Almarai (dairy & foodstuff)',
                'Julphar (pharmaceuticals)',
                'Dabur International (FMCG)',
              ],
              Colors.green,
              Icons.inventory,
            ),
            const SizedBox(height: 28),

            // Investment Insights
            _buildSectionHeader(
              'Investment Intelligence',
              Icons.lightbulb_outline,
              Colors.amber,
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              'Revenue Proxy Hierarchy',
              'Highest to Lowest Certainty',
              [
                '1. Public Listing (ADGM) - Verifiable market cap',
                '2. Fortune 500 Status (JAFZA) - Global corporate power',
                '3. G-SIB Designation (DIFC) - Systemic importance',
                '4. Long-term CapEx (KEZAD) - 50-year lease commitments',
                '5. Trading Volume (DMCC) - High transaction throughput',
                '6. Aggregate Volume (AFZ) - 20,000+ company diversity',
              ],
              Colors.blue,
            ),
            _buildInsightCard(
              'Strategic Integration Benefits',
              'DIFC-JAFZA Dual-Zone Framework',
              [
                'Financial governance (DIFC common law) + Trade efficiency (JAFZA infrastructure)',
                'Family offices & foundations in DIFC for succession planning',
                'Manufacturing & warehousing in JAFZA for duty exemptions',
                'Seamless capital structure supporting logistics speed',
                'Dubai Economic Agenda (D33) alignment',
              ],
              Colors.purple,
            ),
            _buildInsightCard(
              'Profit Strategy Divergence',
              'Volume vs. Margin Optimization',
              [
                'High-Volume Model: AFZ with 20,000+ companies generating aggregate revenue',
                'High-Margin Model: SHAMS with capital-light service firms (no audits, 100% profit repatriation)',
                'Example: \$50M software firm (SHAMS) may achieve higher net profit than \$500M commodity trader (AFZ)',
                'Key: Operational overhead and compliance requirements drive profit margins',
              ],
              Colors.green,
            ),
            const SizedBox(height: 24),

            // Call to action
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.explore, size: 48, color: AppColors.purple),
                  const SizedBox(height: 12),
                  const Text(
                    'Ready to Explore Free Zones?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use our Free Zone Browser to compare, filter, and find the perfect zone for your business strategy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Go back to home
                      // Navigate to Free Zone Browser
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Browse Free Zones'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildAlignmentTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTableRow(
              'Free Zone Cluster',
              'Primary Revenue Proxy',
              isHeader: true,
            ),
            const Divider(height: 20),
            _buildTableRow(
              'Global Finance (DIFC, ADGM)',
              'G-SIB concentration / AUM',
            ),
            _buildTableRow(
              'Heavy Trade & Logistics (JAFZA, Dubai South)',
              'Fortune 500 / CapEx',
            ),
            _buildTableRow('Commodities (DMCC)', 'Trading Volume'),
            _buildTableRow(
              'Industrial (KEZAD, HFZA)',
              'Long-term CapEx / Leases',
            ),
            _buildTableRow(
              'Digital Services (DIC, Masdar, SHAMS)',
              'Regional Licensing / R&D',
            ),
            _buildTableRow(
              'Manufacturing & FMCG (RAKEZ)',
              'Market Penetration',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(String col1, String col2, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              col1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
                color: isHeader ? AppColors.purple : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              col2,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? AppColors.purple : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTakeaway(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClusterCard(
    String title,
    String zones,
    String revenueProxy,
    List<String> anchors,
    Color color,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                zones,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Revenue Proxy: $revenueProxy',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Text(
                  'Top Anchor Tenants:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                ...anchors.map(
                  (anchor) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            anchor,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String subtitle,
    List<String> points,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.insights, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ...points.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About This Report'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This strategic investment benchmark analyzes UAE free zones through revenue proxies and anchor tenant profiles.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 12),
              const Text(
                'Key Methodology:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              const Text(
                '• Fortune 500 status and G-SIB designation as corporate power indicators\n'
                '• Market capitalization for publicly listed entities\n'
                '• Long-term CapEx commitments (50-year leases)\n'
                '• Trading volume and transaction throughput\n'
                '• Assets Under Management (AUM) for financial centers',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Source: Comprehensive analysis of UAE free zone data, public listings, and corporate registrations (2024-2025)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
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
      ),
    );
  }
}
