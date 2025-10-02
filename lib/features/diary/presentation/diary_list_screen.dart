import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/diary.dart';
import '../../../services/diary_service.dart';
import 'diary_write_screen.dart';
import 'diary_detail_screen.dart';

/// 일기 목록 화면
class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  final DiaryService _diaryService = DiaryService.instance;
  List<Diary> _diaries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  /// 일기 목록 로드
  Future<void> _loadDiaries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final diaries = await _diaryService.getUserDiaries(includeDrafts: true);
      setState(() {
        _diaries = diaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }


  /// 오프라인 동기화
  Future<void> _syncOfflineData() async {
    try {
      await _diaryService.syncOfflineData();
      await _loadDiaries();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('오프라인 데이터가 동기화되었습니다.'),
            backgroundColor: Color(0xFF00D884),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('동기화 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 일기'),
        backgroundColor: const Color(0xFF00D884),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _syncOfflineData,
            icon: const Icon(Icons.sync),
            tooltip: '오프라인 동기화',
          ),
          IconButton(
            onPressed: _loadDiaries,
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DiaryWriteScreen(),
            ),
          );
          
          // 일기 작성 후 목록 새로고침
          if (result != null) {
            _loadDiaries();
          }
        },
        backgroundColor: const Color(0xFF00D884),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D884)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDiaries,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D884),
                foregroundColor: Colors.white,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_diaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book_outlined,
              size: 64,
              color: Color(0xFF00D884),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 작성된 일기가 없습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '첫 번째 일기를 작성해보세요!',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDiaries,
      color: const Color(0xFF00D884),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _diaries.length,
        itemBuilder: (context, index) {
          final diary = _diaries[index];
          return _buildDiaryCard(diary);
        },
      ),
    );
  }

  Widget _buildDiaryCard(Diary diary) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryDetailScreen(diary: diary),
            ),
          );
          
          // 일기 수정 후 목록 새로고침
          if (result != null) {
            _loadDiaries();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목과 상태
              Row(
                children: [
                  Expanded(
                    child: Text(
                      diary.title ?? '제목 없음',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (diary.isDraft)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '임시저장',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 기분과 날씨
              if (diary.mood != null || diary.weather != null)
                Row(
                  children: [
                    if (diary.mood != null)
                      Text(
                        diary.mood!,
                        style: const TextStyle(fontSize: 20),
                      ),
                    if (diary.mood != null && diary.weather != null)
                      const SizedBox(width: 8),
                    if (diary.weather != null)
                      Text(
                        diary.weather!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              
              const SizedBox(height: 8),
              
              // 내용 미리보기
              Text(
                diary.content,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // 하단 정보
              Row(
                children: [
                  // 위치
                  if (diary.location != null)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            diary.location!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // 날짜
                  Text(
                    DateFormat('yyyy.MM.dd HH:mm').format(diary.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
