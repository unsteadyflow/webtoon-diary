import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/diary.dart';
import '../../../services/diary_service.dart';

/// 일기 상세 화면
class DiaryDetailScreen extends StatefulWidget {
  final Diary diary;

  const DiaryDetailScreen({
    super.key,
    required this.diary,
  });

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  final DiaryService _diaryService = DiaryService.instance;
  late Diary _diary;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _diary = widget.diary;
  }

  /// 일기 삭제
  Future<void> _deleteDiary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일기 삭제'),
        content: const Text('정말로 이 일기를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _diaryService.deleteDiary(_diary.id);
        
        if (mounted) {
          Navigator.pop(context, true); // 삭제 완료 신호
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('일기가 삭제되었습니다.'),
              backgroundColor: Color(0xFF00D884),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제 중 오류가 발생했습니다: $e'),
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
  }

  /// 일기 수정
  Future<void> _editDiary() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryEditScreen(diary: _diary),
      ),
    );

    if (result != null && mounted) {
      // 수정된 일기 정보 업데이트
      setState(() {
        _diary = result;
      });
      
      // 수정 완료 신호
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_diary.title ?? '일기'),
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
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editDiary();
                    break;
                  case 'delete':
                    _deleteDiary();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('수정'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            if (_diary.title != null)
              Text(
                _diary.title!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            
            const SizedBox(height: 16),
            
            // 메타 정보
            _buildMetaInfo(),
            
            const SizedBox(height: 20),
            
            // 내용
            Text(
              _diary.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // AI 만화 생성 버튼 (임시저장이 아닌 경우만)
            if (!_diary.isDraft)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // AI 만화 생성 기능은 추후 구현 예정
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('AI 만화 생성 기능은 추후 구현 예정입니다.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('AI 만화 만들기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D884),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 메타 정보 위젯
  Widget _buildMetaInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // 기분과 날씨
          if (_diary.mood != null || _diary.weather != null)
            Row(
              children: [
                if (_diary.mood != null)
                  Row(
                    children: [
                      const Text('기분: '),
                      Text(
                        _diary.mood!,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                if (_diary.mood != null && _diary.weather != null)
                  const SizedBox(width: 20),
                if (_diary.weather != null)
                  Text('날씨: ${_diary.weather}'),
              ],
            ),
          
          if (_diary.mood != null || _diary.weather != null)
            const SizedBox(height: 12),
          
          // 위치
          if (_diary.location != null)
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _diary.location!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          
          if (_diary.location != null)
            const SizedBox(height: 12),
          
          // 작성일과 수정일
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '작성일',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      DateFormat('yyyy년 MM월 dd일 HH:mm').format(_diary.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              if (_diary.updatedAt != _diary.createdAt)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '수정일',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        DateFormat('yyyy년 MM월 dd일 HH:mm').format(_diary.updatedAt),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          // 상태 표시
          if (_diary.isDraft)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '임시저장',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 일기 수정 화면
class DiaryEditScreen extends StatefulWidget {
  final Diary diary;

  const DiaryEditScreen({
    super.key,
    required this.diary,
  });

  @override
  State<DiaryEditScreen> createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends State<DiaryEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  final DiaryService _diaryService = DiaryService.instance;
  
  bool _isLoading = false;
  bool _isDraft = false;
  String? _selectedMood;
  String? _selectedWeather;
  String? _selectedLocation;
  
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
    _titleController.text = widget.diary.title ?? '';
    _contentController.text = widget.diary.content;
    _isDraft = widget.diary.isDraft;
    _selectedMood = widget.diary.mood;
    _selectedWeather = widget.diary.weather;
    _selectedLocation = widget.diary.location;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 일기 수정 저장
  Future<void> _updateDiary() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedDiary = await _diaryService.updateDiary(
        diaryId: widget.diary.id,
        content: _contentController.text,
        title: _titleController.text.trim().isEmpty ? null : _titleController.text,
        mood: _selectedMood,
        weather: _selectedWeather,
        location: _selectedLocation,
        isDraft: _isDraft,
      );

      if (mounted) {
        Navigator.pop(context, updatedDiary);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('일기가 수정되었습니다.'),
            backgroundColor: Color(0xFF00D884),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('수정 중 오류가 발생했습니다: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 수정'),
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
              onPressed: _updateDiary,
              child: const Text(
                '저장',
                style: TextStyle(
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
                ],
              ),
              
              const SizedBox(height: 30),
              
              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateDiary,
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
                      : const Text(
                          '수정 완료',
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
