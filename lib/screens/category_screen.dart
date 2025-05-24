import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialCondition;

  const CategoryScreen({
    super.key,
    this.initialCategory,
    this.initialCondition,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selectedCategory = '';
  String _selectedCondition = '';

  final List<String> categories = [
    'All',
    'Light Novel',
    'Novel',
    'Manhwa',
    'Manhua',
    'Manga',
  ];

  final List<String> conditions = ['Semua Kondisi', 'Baru', 'Bekas'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? '';
    _selectedCondition = widget.initialCondition ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(252, 51, 78, 197),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Filter Comic',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        252,
                        51,
                        78,
                        197,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromARGB(
                          252,
                          51,
                          78,
                          197,
                        ).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              color: const Color.fromARGB(252, 51, 78, 197),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Pilih Kategori dan Kondisi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(252, 51, 78, 197),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pilih kategori dan kondisi keinginanmu untuk menemukan komik yang tepat.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromARGB(
                          252,
                          51,
                          78,
                          197,
                        ).withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value:
                            _selectedCategory.isEmpty
                                ? 'All'
                                : _selectedCategory,
                        isExpanded: true,
                        hint: const Text('Pilih Katasdasdwegori'),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color.fromARGB(252, 51, 78, 197),
                          size: 28,
                        ),
                        items:
                            categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory =
                                newValue == 'All' ? '' : newValue!;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    'Pilih Kategori',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        categories.map((category) {
                          return _buildCategoryChip(category);
                        }).toList(),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'Kondisi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromARGB(
                          252,
                          51,
                          78,
                          197,
                        ).withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value:
                            _selectedCondition.isEmpty
                                ? 'Semua Kondisi'
                                : _selectedCondition,
                        isExpanded: true,
                        hint: const Text('Pilih Kondisi'),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color.fromARGB(252, 51, 78, 197),
                          size: 28,
                        ),
                        items:
                            conditions.map((String condition) {
                              return DropdownMenuItem<String>(
                                value: condition,
                                child: Row(
                                  children: [
                                    if (condition != 'Semua Kondisi')
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: _getConditionColor(condition),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    if (condition != 'Semua Kondisi')
                                      const SizedBox(width: 10),
                                    Text(
                                      condition,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCondition =
                                newValue == 'Semua Kondisi' ? '' : newValue!;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = '';
                                _selectedCondition = '';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color.fromARGB(
                                252,
                                51,
                                78,
                                197,
                              ),
                              side: const BorderSide(
                                color: Color.fromARGB(252, 51, 78, 197),
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Bersihkan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, {
                                'category': _selectedCategory,
                                'condition': _selectedCondition,
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                252,
                                51,
                                78,
                                197,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Terapkan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected =
        _selectedCategory == category ||
        (category == "All" && _selectedCategory.isEmpty);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category == "All" ? '' : category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color.fromARGB(252, 51, 78, 197)
                  : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color.fromARGB(252, 51, 78, 197),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          category,
          style: TextStyle(
            color:
                isSelected
                    ? Colors.white
                    : const Color.fromARGB(252, 51, 78, 197),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildConditionChip(String condition) {
    final isSelected =
        _selectedCondition == condition ||
        (condition == "Semua Kondisi" && _selectedCondition.isEmpty);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCondition = condition == "Semua Kondisi" ? '' : condition;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color.fromARGB(252, 51, 78, 197)
                  : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color.fromARGB(252, 51, 78, 197),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (condition != 'Semua Kondisi')
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.white : _getConditionColor(condition),
                  shape: BoxShape.circle,
                ),
              ),
            if (condition != 'Semua Kondisi') const SizedBox(width: 6),
            Text(
              condition,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : const Color.fromARGB(252, 51, 78, 197),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'baru':
        return Colors.green;
      case 'bekas':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
