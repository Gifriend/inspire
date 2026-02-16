import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/widgets/widgets.dart';

class CourseManagementScreen extends ConsumerStatefulWidget {
  final int kelasId;
  final String courseName;

  const CourseManagementScreen({
    super.key,
    required this.kelasId,
    required this.courseName,
  });

  @override
  ConsumerState<CourseManagementScreen> createState() =>
      _CourseManagementScreenState();
}

class _CourseManagementScreenState
    extends ConsumerState<CourseManagementScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      appBar: AppBarWidget(title: widget.courseName),
      child: Column(
        children: [
          // Tab navigation
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab('Materi', 0),
                  _buildTab('Tugas', 1),
                  _buildTab('Kuis', 2),
                  _buildTab('Submissions', 3),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Tab content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? BaseColor.primaryInspire : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? BaseColor.primaryInspire
                : BaseColor.primaryText.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildMaterialTab();
      case 1:
        return _buildAssignmentTab();
      case 2:
        return _buildQuizTab();
      case 3:
        return _buildSubmissionsTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildMaterialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showMaterialForm(),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Materi'),
          ),
          const SizedBox(height: 20),
          // List placeholder
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) => _buildMaterialCard(index),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.description, color: BaseColor.primaryInspire, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Materi ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Minggu ${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: BaseColor.primaryText.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Edit')),
              const PopupMenuItem(child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showAssignmentForm(),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Tugas'),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index) => _buildAssignmentCard(index),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: Colors.green, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tugas ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Deadline: ${DateTime.now().add(Duration(days: index + 3))}',
                      style: TextStyle(
                        fontSize: 12,
                        color: BaseColor.primaryText.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(child: Text('Lihat Submissions')),
                  const PopupMenuItem(child: Text('Edit')),
                  const PopupMenuItem(child: Text('Hapus')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Submission stats
          Row(
            children: [
              Expanded(
                child: _buildStatBadge('5', 'Total'), 
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBadge('3', 'Dikumpul'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBadge('2', 'Belum'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showQuizForm(),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Kuis'),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index) => _buildQuizCard(index),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz, color: Colors.orange, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kuis ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '10 soal • 30 menit',
                      style: TextStyle(
                        fontSize: 12,
                        color: BaseColor.primaryText.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(child: Text('Lihat Hasil')),
                  const PopupMenuItem(child: Text('Edit')),
                  const PopupMenuItem(child: Text('Hapus')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBadge('5', 'Attempt'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBadge('3', 'Lulus'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBadge('2', 'Tidak'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submissions Belum Dinilai',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: BaseColor.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) => _buildSubmissionCard(index),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.pending, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mahasiswa ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tugas 1 • Dikumpul',
                  style: TextStyle(
                    fontSize: 12,
                    color: BaseColor.primaryText.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showGradingForm(),
            child: const Text('Nilai'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: BaseColor.primaryInspire.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: BaseColor.primaryInspire,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: BaseColor.primaryInspire.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showMaterialForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Materi'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Judul Materi',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Tipe',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAssignmentForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tugas'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Judul Tugas',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Deadline',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }

  void _showQuizForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kuis'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Judul Kuis',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Durasi (menit)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Pertanyaan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }

  void _showGradingForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Berikan Nilai'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nilai (0-100)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Feedback',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Simpan Nilai'),
          ),
        ],
      ),
    );
  }
}
