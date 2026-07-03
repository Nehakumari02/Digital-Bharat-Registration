import 'package:flutter/material.dart';

class InterviewPrepScreen extends StatefulWidget {
  const InterviewPrepScreen({super.key});

  @override
  State<InterviewPrepScreen> createState() => _InterviewPrepScreenState();
}

class _InterviewPrepScreenState extends State<InterviewPrepScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Interview Prep Hub', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        elevation: 1,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2196F3),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2196F3),
          tabs: const [
            Tab(text: 'Top Tips'),
            Tab(text: 'Questions'),
            Tab(text: 'Checklist'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTipsTab(),
          _buildQuestionsTab(),
          _buildChecklistTab(),
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _tipCard(
          'The STAR Method',
          'Use this to answer behavioral questions:',
          Icons.star_border,
          [
            'Situation: Set the scene and give necessary details.',
            'Task: Describe what your responsibility was.',
            'Action: Explain exactly what steps you took.',
            'Result: Share what outcomes your actions achieved.',
          ],
        ),
        _tipCard(
          'Research the Company',
          'Before the interview, make sure you know:',
          Icons.search,
          [
            'The company\'s core mission and values.',
            'Recent news or product launches.',
            'The exact requirements listed in the job description.',
          ],
        ),
        _tipCard(
          'Body Language',
          'Non-verbal communication is key:',
          Icons.person_outline,
          [
            'Maintain good eye contact (look at the camera for video calls).',
            'Sit up straight and avoid crossing your arms.',
            'Smile and nod to show active listening.',
          ],
        ),
      ],
    );
  }

  Widget _tipCard(String title, String subtitle, IconData icon, List<String> points) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2196F3), size: 28),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ...points.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 16)),
                  Expanded(child: Text(p, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsTab() {
    final questions = [
      {
        'q': 'Tell me about yourself.',
        'why': 'The interviewer wants to see if you can communicate clearly and learn about your professional journey.',
        'how': 'Keep it professional. Briefly mention your current role, highlight 1-2 major past achievements, and explain why you are excited about this specific opportunity.',
      },
      {
        'q': 'What is your greatest weakness?',
        'why': 'To test your self-awareness and willingness to improve.',
        'how': 'Choose a real, but minor weakness that isn\'t critical for the job. Immediately follow up with the steps you are actively taking to improve it.',
      },
      {
        'q': 'Why do you want to work here?',
        'why': 'To see if you actually researched the company and are passionate about their mission.',
        'how': 'Mention specific things you admire about the company (culture, product, recent news) and connect them to your own career goals and values.',
      },
      {
        'q': 'Where do you see yourself in 5 years?',
        'why': 'To understand your ambition and see if your long-term goals align with what the company can offer.',
        'how': 'Express excitement about growing your skills and taking on more responsibility within the industry or company. Avoid mentioning titles that are too specific.',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final q = questions[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(q['q']!, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            iconColor: const Color(0xFF2196F3),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              _qaSection('Why they ask this:', q['why']!),
              const SizedBox(height: 12),
              _qaSection('How to answer:', q['how']!),
            ],
          ),
        );
      },
    );
  }

  Widget _qaSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
        const SizedBox(height: 4),
        Text(content, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildChecklistTab() {
    return const _ChecklistWidget();
  }
}

class _ChecklistWidget extends StatefulWidget {
  const _ChecklistWidget();

  @override
  State<_ChecklistWidget> createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends State<_ChecklistWidget> {
  final List<Map<String, dynamic>> _checklist = [
    {'task': 'Research the company and interviewers', 'done': false},
    {'task': 'Review the job description thoroughly', 'done': false},
    {'task': 'Prepare 2-3 questions to ask them', 'done': false},
    {'task': 'Test internet connection & camera (if online)', 'done': false},
    {'task': 'Find a quiet, well-lit place (if online)', 'done': false},
    {'task': 'Print copies of your resume (if in-person)', 'done': false},
    {'task': 'Plan your commute & arrive 10 mins early', 'done': false},
    {'task': 'Dress appropriately for the role', 'done': false},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _checklist.length,
      itemBuilder: (context, index) {
        final item = _checklist[index];
        return CheckboxListTile(
          value: item['done'],
          activeColor: const Color(0xFF2196F3),
          title: Text(
            item['task'],
            style: TextStyle(
              decoration: item['done'] ? TextDecoration.lineThrough : null,
              color: item['done'] ? Colors.grey : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          onChanged: (val) {
            setState(() {
              item['done'] = val;
            });
          },
        );
      },
    );
  }
}
