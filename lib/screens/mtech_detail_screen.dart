import 'package:flutter/material.dart';

class MtechDetailScreen extends StatelessWidget {
  const MtechDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'M.Tech Program',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Master of Technology',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats Row
                  _buildQuickStats(),
                  const SizedBox(height: 20),

                  // About Section
                  _buildSectionCard(
                    icon: Icons.info_outline,
                    title: 'About M.Tech',
                    color: const Color(0xFF1A237E),
                    child: const Text(
                      'Master of Technology (M.Tech) is a postgraduate engineering degree that provides advanced knowledge and skills in a specific engineering or technology discipline. It is designed to develop highly skilled engineers and researchers who can contribute to technological innovation and industrial development.',
                      style: TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Eligibility Section
                  _buildSectionCard(
                    icon: Icons.check_circle_outline,
                    title: 'Eligibility Criteria',
                    color: Colors.green,
                    child: Column(
                      children: [
                        _buildBulletPoint('B.Tech / B.E. degree in relevant engineering field'),
                        _buildBulletPoint('Minimum 55% aggregate marks (50% for SC/ST)'),
                        _buildBulletPoint('Valid GATE score (for government colleges)'),
                        _buildBulletPoint('Some universities accept without GATE via entrance exam'),
                        _buildBulletPoint('Age limit: Generally no upper age limit'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Duration & Structure
                  _buildSectionCard(
                    icon: Icons.calendar_today,
                    title: 'Duration & Structure',
                    color: Colors.orange,
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.timer, 'Duration', '2 Years (4 Semesters)'),
                        const Divider(height: 20),
                        _buildInfoRow(Icons.book, 'Semester 1 & 2', 'Core Subjects + Electives'),
                        _buildInfoRow(Icons.science, 'Semester 3', 'Research / Project Work'),
                        _buildInfoRow(Icons.assignment, 'Semester 4', 'Thesis / Dissertation'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Specializations
                  _buildSectionCard(
                    icon: Icons.category,
                    title: 'Popular Specializations',
                    color: Colors.purple,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip('Computer Science & Engineering', Colors.blue),
                        _buildChip('Artificial Intelligence & ML', Colors.indigo),
                        _buildChip('Data Science', Colors.teal),
                        _buildChip('VLSI Design', Colors.deepPurple),
                        _buildChip('Structural Engineering', Colors.brown),
                        _buildChip('Power Systems', Colors.amber),
                        _buildChip('Thermal Engineering', Colors.red),
                        _buildChip('Robotics & Automation', Colors.cyan),
                        _buildChip('Embedded Systems', Colors.green),
                        _buildChip('Communication Systems', Colors.orange),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subjects
                  _buildSectionCard(
                    icon: Icons.menu_book,
                    title: 'Core Subjects',
                    color: Colors.teal,
                    child: Column(
                      children: [
                        _buildSubjectTile('Advanced Algorithms & Data Structures', '1st Sem'),
                        _buildSubjectTile('Research Methodology', '1st Sem'),
                        _buildSubjectTile('Advanced Mathematics', '1st Sem'),
                        _buildSubjectTile('Machine Learning & AI', '2nd Sem'),
                        _buildSubjectTile('Cloud Computing', '2nd Sem'),
                        _buildSubjectTile('Cyber Security', '2nd Sem'),
                        _buildSubjectTile('Project / Thesis Work', '3rd & 4th Sem'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fee Structure
                  _buildSectionCard(
                    icon: Icons.currency_rupee,
                    title: 'Fee Structure',
                    color: Colors.green,
                    child: Column(
                      children: [
                        _buildFeeRow('Government Colleges', '₹20,000 – ₹1,00,000 / year'),
                        const Divider(height: 16),
                        _buildFeeRow('Private Colleges', '₹80,000 – ₹3,00,000 / year'),
                        const Divider(height: 16),
                        _buildFeeRow('IITs / NITs', '₹25,000 – ₹1,50,000 / year'),
                        const Divider(height: 16),
                        _buildFeeRow('GATE Scholarship', '₹12,400 / month (MHRD)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Career Opportunities
                  _buildSectionCard(
                    icon: Icons.work_outline,
                    title: 'Career Opportunities',
                    color: Colors.deepOrange,
                    child: Column(
                      children: [
                        _buildCareerTile(Icons.computer, 'Software Engineer / Architect', '₹8L – ₹30L per annum'),
                        _buildCareerTile(Icons.analytics, 'Data Scientist / ML Engineer', '₹10L – ₹35L per annum'),
                        _buildCareerTile(Icons.account_balance, 'Research Scientist', '₹6L – ₹20L per annum'),
                        _buildCareerTile(Icons.school, 'Assistant Professor', '₹5L – ₹15L per annum'),
                        _buildCareerTile(Icons.engineering, 'Systems Engineer', '₹7L – ₹25L per annum'),
                        _buildCareerTile(Icons.business, 'Technical Consultant', '₹10L – ₹40L per annum'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Top Colleges
                  _buildSectionCard(
                    icon: Icons.location_city,
                    title: 'Top Colleges in India',
                    color: Colors.indigo,
                    child: Column(
                      children: [
                        _buildCollegeTile('IIT Bombay', 'Mumbai, Maharashtra', '🏆'),
                        _buildCollegeTile('IIT Delhi', 'New Delhi', '🏆'),
                        _buildCollegeTile('IIT Madras', 'Chennai, Tamil Nadu', '🏆'),
                        _buildCollegeTile('NIT Trichy', 'Tiruchirappalli, Tamil Nadu', '⭐'),
                        _buildCollegeTile('BITS Pilani', 'Pilani, Rajasthan', '⭐'),
                        _buildCollegeTile('VIT Vellore', 'Vellore, Tamil Nadu', '⭐'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Admission Process
                  _buildSectionCard(
                    icon: Icons.how_to_reg,
                    title: 'Admission Process',
                    color: Colors.cyan,
                    child: Column(
                      children: [
                        _buildStepTile('1', 'Appear for GATE Exam', 'Conducted every February'),
                        _buildStepTile('2', 'Check Cutoff & Apply', 'Apply to colleges via COAP/CCMT'),
                        _buildStepTile('3', 'Document Verification', 'Submit required documents'),
                        _buildStepTile('4', 'Counselling / Interview', 'Attend college counselling'),
                        _buildStepTile('5', 'Fee Payment & Enrollment', 'Complete admission formalities'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Skills Gained
                  _buildSectionCard(
                    icon: Icons.lightbulb_outline,
                    title: 'Skills You Will Gain',
                    color: Colors.amber,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSkillChip('Research & Analysis'),
                        _buildSkillChip('Problem Solving'),
                        _buildSkillChip('Technical Writing'),
                        _buildSkillChip('Programming'),
                        _buildSkillChip('Project Management'),
                        _buildSkillChip('Critical Thinking'),
                        _buildSkillChip('Data Analysis'),
                        _buildSkillChip('Innovation'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────────────────

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatCard('2 Years', 'Duration', Icons.schedule, Colors.blue),
        const SizedBox(width: 10),
        _buildStatCard('PG Degree', 'Level', Icons.grade, Colors.green),
        const SizedBox(width: 10),
        _buildStatCard('GATE', 'Entrance', Icons.assignment_turned_in, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Section Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSubjectTile(String subject, String semester) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(subject, style: const TextStyle(fontSize: 14, color: Colors.black87))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(semester, style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String type, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(type, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
      ],
    );
  }

  Widget _buildCareerTile(IconData icon, String role, String salary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.deepOrange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(salary, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollegeTile(String name, String location, String badge) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(badge, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTile(String step, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(color: Colors.cyan, shape: BoxShape.circle),
            child: Center(
              child: Text(step, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
