import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/diary_comic.dart';
import '../../../services/diary_service.dart';
import '../../diary/presentation/diary_write_screen.dart';
import '../../diary/presentation/diary_detail_screen.dart';

/// 메인 피드 화면
/// 일기와 만화를 카드형 UI로 표시하는 화면
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final DiaryService _diaryService = DiaryService.instance;
  List<DiaryComic> _diaryComics = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  /// 피드 데이터 로드
  Future<void> _loadFeed() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final diaryComics = await _diaryService.getDiaryComicsFeed(
        includeDrafts: false,
      );
      setState(() {
        _diaryComics = diaryComics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '피드를 불러오는 중 오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
  }

  /// 새로고침
  Future<void> _refreshFeed() async {
    await _loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        color: const Color(0xFF00D884),
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDiaryWrite(context),
        backgroundColor: const Color(0xFF00D884),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 본문 위젯 빌드
  Widget _buildBody() {
    if (_isLoading) {
      return _buildSkeletonLoading();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_diaryComics.isEmpty) {
      return _buildEmptyState();
    }

    return _buildFeedList();
  }

  /// 스켈레톤 로딩 UI
  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // 로딩 중 표시할 카드 수
      itemBuilder: (context, index) {
        return _buildSkeletonCard();
      },
    );
  }

  /// 스켈레톤 카드
  Widget _buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 영역
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
            // 내용 영역
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: 200,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 150,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 에러 상태 UI
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              _errorMessage ?? '알 수 없는 오류가 발생했습니다',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadFeed,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_stories,
              size: 100,
              color: Color(0xFF00D884),
            ),
            const SizedBox(height: 24),
            const Text(
              '아직 작성한 일기가 없습니다',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '첫 번째 일기를 작성해보세요!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToDiaryWrite(context),
              icon: const Icon(Icons.add),
              label: const Text('일기 작성하기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 피드 리스트 UI
  Widget _buildFeedList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _diaryComics.length,
      itemBuilder: (context, index) {
        final diaryComic = _diaryComics[index];
        return _buildFeedCard(diaryComic);
      },
    );
  }

  /// 피드 카드 UI
  Widget _buildFeedCard(DiaryComic diaryComic) {
    final diary = diaryComic.diary;
    final hasComic = diaryComic.hasComic;
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    final timeFormat = DateFormat('HH:mm');

    return GestureDetector(
      onTap: () => _navigateToDetail(context, diaryComic),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 만화 썸네일 또는 일기 미리보기
            if (hasComic && diaryComic.comicThumbnailUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: diaryComic.comicThumbnailUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00D884),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_stories,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
              ),
            // 카드 내용
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 및 시간
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(diary.createdAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeFormat.format(diary.createdAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 제목 또는 내용 미리보기
                  if (diary.title != null && diary.title!.isNotEmpty)
                    Text(
                      diary.title!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (diary.title != null && diary.title!.isNotEmpty)
                    const SizedBox(height: 8),
                  // 내용 미리보기
                  Text(
                    diary.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // 만화 상태 표시
                  if (hasComic)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D884).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.image,
                            size: 16,
                            color: Color(0xFF00D884),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '만화 생성됨',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_note,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '만화 미생성',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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

  /// 일기 작성 화면으로 이동
  void _navigateToDiaryWrite(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DiaryWriteScreen(),
      ),
    ).then((_) {
      // 일기 작성 후 피드 새로고침
      _refreshFeed();
    });
  }

  /// 상세 보기 화면으로 이동
  void _navigateToDetail(BuildContext context, DiaryComic diaryComic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryDetailScreen(diaryId: diaryComic.diary.id),
      ),
    ).then((_) {
      // 상세 화면에서 돌아온 후 피드 새로고침
      _refreshFeed();
    });
  }
}
