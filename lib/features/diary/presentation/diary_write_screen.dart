import 'dart:async';
import 'package:flutter/material.dart';
import '../../../services/diary_service.dart';

/// 일기 작성 화면
class DiaryWriteScreen extends StatefulWidget {
  const DiaryWriteScreen({super.key});

  @override
  State<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends State<DiaryWriteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  final DiaryService _diaryService = DiaryService.instance;
  
  bool _isLoading = false;
  bool _isDraft = false;
  String? _selectedMood;
  String? _selectedWeather;
  String? _selectedLocation;
  
  Timer? _autoSaveTimer;
  
  // 기분 옵션
  final List<String> _moodOptions = [
    '😊', '😄', '😍', '🥰', '😎', '🤔', '😐', '😔', '😢', '😭', '😤', '😡'
  ];
  
  // 날씨 옵션
  final List<String> _weatherOptions = [
    '☀️ 맑음', '⛅ 흐림', '☁️ 구름', '🌧️ 비', '⛈️ 천둥', '❄️ 눈', '🌪️ 바람'
  ];

  @override
  void initState() {
    super.initState();
    _setupAutoSave();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  /// 자동저장 설정
  void _setupAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_contentController.text.trim().isNotEmpty) {
        _autoSave();
      }
    });
  }

  /// 자동저장 실행
  Future<void> _autoSave() async {
    try {
      await _diaryService.autoSaveDraft(
        content: _contentController.text,
        title: _titleController.text.trim().isEmpty ? null : _titleController.text,
        mood: _selectedMood,
        weather: _selectedWeather,
        location: _selectedLocation,
      );
    } catch (e) {
      // 자동저장 실패는 사용자에게 알리지 않음
    }
  }

  /// 일기 저장
  Future<void> _saveDiary() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await _diaryService.createDiary(
        content: _contentController.text,
        title: _titleController.text.trim().isEmpty ? null : _titleController.text,
        mood: _selectedMood,
        weather: _selectedWeather,
        location: _selectedLocation,
        isDraft: _isDraft,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isDraft ? '임시저장되었습니다.' : '일기가 저장되었습니다.'),
            backgroundColor: const Color(0xFF00D884),
          ),
        );

        // 작성 완료 시 AI 만화 생성 플로우로 이동
        if (!_isDraft) {
          _navigateToComicGeneration();
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// AI 만화 생성 화면으로 이동
  void _navigateToComicGeneration() {
    // AI 만화 생성 화면으로 네비게이션 (추후 구현 예정)
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI 만화 생성 기능은 추후 구현 예정입니다.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 작성'),
        backgroundColor: const Color(0xFF00D884),
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveDiary,
              child: Text(
                _isDraft ? '임시저장' : '저장',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 입력
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: '제목 (선택사항)',
                  hintText: '오늘의 일기를 한 줄로 표현해보세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00D884), width: 2),
                  ),
                ),
                maxLines: 1,
              ),
              
              const SizedBox(height: 20),
              
              // 기분 선택
              _buildMoodSelector(),
              
              const SizedBox(height: 20),
              
              // 날씨 선택
              _buildWeatherSelector(),
              
              const SizedBox(height: 20),
              
              // 위치 입력
              TextFormField(
                controller: TextEditingController(text: _selectedLocation),
                onChanged: (value) => _selectedLocation = value,
                decoration: InputDecoration(
                  labelText: '위치 (선택사항)',
                  hintText: '어디서 쓴 일기인가요?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00D884), width: 2),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                maxLines: 1,
              ),
              
              const SizedBox(height: 20),
              
              // 일기 내용 입력
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: '일기 내용 *',
                  hintText: '오늘 하루는 어떠셨나요? 자유롭게 작성해보세요.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00D884), width: 2),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 15,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '일기 내용을 입력해주세요.';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // 저장 옵션
              Row(
                children: [
                  Checkbox(
                    value: _isDraft,
                    onChanged: (value) {
                      setState(() {
                        _isDraft = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF00D884),
                  ),
                  const Text('임시저장'),
                  const Spacer(),
                  Text(
                    '자동저장: 30초마다',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDiary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D884),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isDraft ? '임시저장하기' : '일기 저장하기',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 기분 선택 위젯
  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '오늘의 기분',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _moodOptions.map((mood) {
            final isSelected = _selectedMood == mood;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMood = isSelected ? null : mood;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00D884).withValues(alpha: 0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF00D884) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  mood,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 날씨 선택 위젯
  Widget _buildWeatherSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '오늘의 날씨',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _weatherOptions.map((weather) {
            final isSelected = _selectedWeather == weather;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedWeather = isSelected ? null : weather;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00D884).withValues(alpha: 0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF00D884) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  weather,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF00D884) : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
