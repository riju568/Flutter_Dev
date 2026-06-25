import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const PremiumSortingVisualizerApp());

class PremiumSortingVisualizerApp extends StatelessWidget {
  const PremiumSortingVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algorithm Visualizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0E15),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1), // Electric Indigo
          secondary: Color(0xFF10B981), // Emerald Green
          surface: Color(0xFF1E1F2E),
        ),
      ),
      home: const SortingVisualizerHome(),
    );
  }
}

class SortingVisualizerHome extends StatefulWidget {
  const SortingVisualizerHome({super.key});

  @override
  State<SortingVisualizerHome> createState() => _SortingVisualizerHomeState();
}

class _SortingVisualizerHomeState extends State<SortingVisualizerHome> {
  List<int> _numbers = [];
  int _sampleSize = 40;
  int _speedMs = 30;
  bool _isSorting = false;
  String _currentAlgorithm = 'Bubble Sort';

  // State indicators for structural colors
  int? _comparingIdx1;
  int? _comparingIdx2;
  int? _swappingIdx1;
  int? _swappingIdx2;
  final Set<int> _sortedIndices = {};

  @override
  void initState() {
    super.initState();
    _resetArray();
  }

  @override
  void dispose() {
    _isSorting = false; // Gracefully halts active async loops on widget removal
    super.dispose();
  }

  void _resetArray() {
    if (_isSorting) return;
    final random = Random();
    setState(() {
      _numbers = List.generate(_sampleSize, (_) => random.nextInt(300) + 15);
      _comparingIdx1 = null;
      _comparingIdx2 = null;
      _swappingIdx1 = null;
      _swappingIdx2 = null;
      _sortedIndices.clear();
    });
  }

  Future<void> _bubbleSort() async {
    int n = _numbers.length;
    for (int i = 0; i < n - 1; i++) {
      for (int j = 0; j < n - i - 1; j++) {
        if (!_isSorting || !mounted) return;

        setState(() {
          _comparingIdx1 = j;
          _comparingIdx2 = j + 1;
          _swappingIdx1 = null;
          _swappingIdx2 = null;
        });

        await Future.delayed(Duration(milliseconds: _speedMs));
        if (!_isSorting || !mounted) return;

        if (_numbers[j] > _numbers[j + 1]) {
          setState(() {
            _swappingIdx1 = j;
            _swappingIdx2 = j + 1;
            int temp = _numbers[j];
            _numbers[j] = _numbers[j + 1];
            _numbers[j + 1] = temp;
          });
          await Future.delayed(Duration(milliseconds: _speedMs));
          if (!_isSorting || !mounted) return;
        }
      }
      setState(() {
        _sortedIndices.add(n - i - 1);
      });
    }
  }

  Future<void> _selectionSort() async {
    int n = _numbers.length;
    for (int i = 0; i < n - 1; i++) {
      int minIdx = i;
      for (int j = i + 1; j < n; j++) {
        if (!_isSorting || !mounted) return;

        setState(() {
          _comparingIdx1 = j;
          _comparingIdx2 = minIdx;
          _swappingIdx1 = null;
          _swappingIdx2 = null;
        });
        await Future.delayed(Duration(milliseconds: _speedMs));
        if (!_isSorting || !mounted) return;

        if (_numbers[j] < _numbers[minIdx]) {
          minIdx = j;
        }
      }
      
      if (minIdx != i) {
        setState(() {
          _swappingIdx1 = i;
          _swappingIdx2 = minIdx;
          int temp = _numbers[minIdx];
          _numbers[minIdx] = _numbers[i];
          _numbers[i] = temp;
        });
        await Future.delayed(Duration(milliseconds: _speedMs));
        if (!_isSorting || !mounted) return;
      }
      setState(() {
        _sortedIndices.add(i);
      });
    }
  }

  void _startSorting() async {
    setState(() {
      _isSorting = true;
      _sortedIndices.clear();
    });

    if (_currentAlgorithm == 'Bubble Sort') {
      await _bubbleSort();
    } else if (_currentAlgorithm == 'Selection Sort') {
      await _selectionSort();
    }

    if (!mounted) return;

    setState(() {
      _isSorting = false;
      _comparingIdx1 = null;
      _comparingIdx2 = null;
      _swappingIdx1 = null;
      _swappingIdx2 = null;
      _sortedIndices.addAll(Iterable.generate(_numbers.length));
    });
  }

  Future<void> _exportToExcel() async {
    try {
      var excel = Excel.createExcel();
      String sheetName = "Simulation Log";
      excel.rename('Sheet1', sheetName);
      Sheet sheetObject = excel[sheetName];

      CellStyle headerStyle = CellStyle(
        bold: true,
        fontColorHex: ExcelColor.fromHexString("#FFFFFF"), // Fixed from HexString constructor
        backgroundColorHex: ExcelColor.fromHexString("#6366F1"), // Fixed from HexString constructor
      );

      sheetObject.appendRow([TextCellValue("Algorithm:"), TextCellValue(_currentAlgorithm)]);
      sheetObject.appendRow([TextCellValue("Total Elements:"), IntCellValue(_numbers.length)]);
      sheetObject.appendRow([TextCellValue("Speed Delay (ms):"), IntCellValue(_speedMs)]);
      sheetObject.appendRow([]); 

      List<CellValue> headers = [
        TextCellValue("Index Position"),
        TextCellValue("Element Value")
      ];
      sheetObject.appendRow(headers);

      int headerRowIndex = 4; 
      for (int i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: headerRowIndex));
        cell.cellStyle = headerStyle;
      }

      for (int i = 0; i < _numbers.length; i++) {
        sheetObject.appendRow([
          IntCellValue(i),
          IntCellValue(_numbers[i]),
        ]);
      }

      List<int>? fileBytes = excel.save();
      if (fileBytes == null) return;
      final byteData = Uint8List.fromList(fileBytes);
      String fileName = "${_currentAlgorithm.replaceAll(' ', '_')}_dataset.xlsx";

      if (kIsWeb) {
        await FilePicker.platform.saveFile(
          fileName: fileName,
          bytes: byteData,
        );
      } else {
        // Appended required 'bytes' field here to resolve mobile OS crash issues
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Sorting Performance Dataset',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
          bytes: byteData,
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsBytes(byteData);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📊 Excel sheet exported successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      debugPrint("Excel Export Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sorting Visualizer',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isSorting ? 'Executing algorithm...' : 'Select settings and run',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1F2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _currentAlgorithm,
                        dropdownColor: const Color(0xFF1E1F2E),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6366F1)),
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                        items: ['Bubble Sort', 'Selection Sort'].map((String val) {
                          return DropdownMenuItem<String>(value: val, child: Text(val));
                        }).toList(),
                        onChanged: _isSorting ? null : (val) => setState(() => _currentAlgorithm = val!),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Color Status Legend Indicator Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildLegendItem(const Color(0xFF6366F1), 'Default'),
                  const SizedBox(width: 16),
                  _buildLegendItem(const Color(0xFFF59E0B), 'Comparing'),
                  const SizedBox(width: 16),
                  _buildLegendItem(const Color(0xFFEF4444), 'Swapping'),
                  const SizedBox(width: 16),
                  _buildLegendItem(const Color(0xFF10B981), 'Sorted'),
                ],
              ),
            ),

            // Rendering Canvas
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF141521),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.03)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                width: double.infinity,
                child: CustomPaint(
                  painter: VisualizerPainter(
                    numbers: _numbers,
                    comparingIdx1: _comparingIdx1,
                    comparingIdx2: _comparingIdx2,
                    swappingIdx1: _swappingIdx1,
                    swappingIdx2: _swappingIdx2,
                    sortedIndices: _sortedIndices,
                  ),
                ),
              ),
            ),

            // Interface Control Panel
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1F2E),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                border: Border.all(color: Colors.white.withOpacity(0.04), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSliderRow("Array Size", _sampleSize.toDouble(), 15, 100, _isSorting, (val) {
                    setState(() => _sampleSize = val.toInt());
                    _resetArray();
                  }),
                  const SizedBox(height: 12),
                  _buildSliderRow("Delay Speed", _speedMs.toDouble(), 5, 200, false, (val) {
                    setState(() => _speedMs = val.toInt());
                  }, unit: "ms"),
                  
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      IconButton.outlined(
                        onPressed: _isSorting ? null : _resetArray,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          side: BorderSide(color: Colors.white.withOpacity(0.12)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isSorting ? null : _exportToExcel,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: const Color(0xFF10B981).withOpacity(0.4)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.table_view_rounded, color: Color(0xFF10B981), size: 20),
                          label: const Text("Export Sheet", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSorting ? null : _startSorting,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: const Text("Run Sort", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max, bool disabled, ValueChanged<double> onChanged, {String unit = ""}) {
    return Row(
      children: [
        SizedBox(
          width: 85,
          child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF6366F1),
              inactiveTrackColor: Colors.white.withOpacity(0.06),
              thumbColor: Colors.white,
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: disabled ? null : onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 45,
          child: Text('${value.toInt()}$unit', textAlign: TextAlign.end, style: const TextStyle(fontSize: 13, color: Color(0xFF6366F1))),
        ),
      ],
    );
  }
}

class VisualizerPainter extends CustomPainter {
  final List<int> numbers;
  final int? comparingIdx1;
  final int? comparingIdx2;
  final int? swappingIdx1;
  final int? swappingIdx2;
  final Set<int> sortedIndices;

  VisualizerPainter({
    required this.numbers,
    this.comparingIdx1,
    this.comparingIdx2,
    this.swappingIdx1,
    this.swappingIdx2,
    required this.sortedIndices,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (numbers.isEmpty) return;

    double canvasWidth = size.width;
    double canvasHeight = size.height;
    double totalSpacing = (numbers.length - 1) * 1.5; 
    double barWidth = (canvasWidth - totalSpacing) / numbers.length;
    if (barWidth < 1.0) barWidth = 1.0; // Prevents negative or sub-pixel viewport artifacts
    
    int maxValue = numbers.reduce(max);

    for (int i = 0; i < numbers.length; i++) {
      double barHeight = (numbers[i] / maxValue) * canvasHeight;

      Paint paint = Paint();
      
      if (i == swappingIdx1 || i == swappingIdx2) {
        paint.color = const Color(0xFFEF4444); // Red
      } else if (i == comparingIdx1 || i == comparingIdx2) {
        paint.color = const Color(0xFFF59E0B); // Amber
      } else if (sortedIndices.contains(i)) {
        paint.color = const Color(0xFF10B981); // Emerald
      } else {
        paint.color = const Color(0xFF6366F1); // Indigo
      }

      RRect roundedBar = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * (barWidth + 1.5),
          canvasHeight - barHeight,
          barWidth,
          barHeight,
        ),
        Radius.circular(barWidth > 8 ? 4 : barWidth / 2),
      );

      canvas.drawRRect(roundedBar, paint);
    }
  }

  @override
  bool shouldRepaint(covariant VisualizerPainter oldDelegate) => true;
}