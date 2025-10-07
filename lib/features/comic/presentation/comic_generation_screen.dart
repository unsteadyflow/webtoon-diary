import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/diary.dart';
import '../../../core/models/comic.dart';
import '../../../services/ai_server_service.dart';
import 'comic_result_screen.dart';

/// 만화 생성 진행 화면
class ComicGenerationScreen extends StatefulWidget {
  final Diary diary;
  final String style;

  const ComicGenerationScreen({
    super.key,
    required this.diary,
    required this.style,
  });

  @override
  State<ComicGenerationScreen> createState() => _ComicGenerationScreenState();
}

class _ComicGenerationScreenState extends State<ComicGenerationScreen> {
  final AiServerService _aiServerService = AiServerService.instance;

  ComicStatus _status = ComicStatus.pending;
  int _etaSeconds = 60;
  StreamSubscription<Comic>? _statusSubscription;

  @override
  void initState() {
    super.initState();
    _startComicGeneration();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  /// 만화 생성 시작
  Future<void> _startComicGeneration() async {
    try {
      setState(() {
        _status = ComicStatus.pending;
        _etaSeconds = 60;
      });

      // AI 서버에 만화 생성 요청
      final response = await _aiServerService.generateComic(
        diaryId: widget.diary.id,
        content: widget.diary.content,
        title: widget.diary.title,
        mood: widget.diary.mood,
        weather: widget.diary.weather,
        location: widget.diary.location,
        style: widget.style,
      );

      // 생성 상태 폴링 시작
      _statusSubscription =
          _aiServerService.pollComicStatus(response.comicId).listen(
        (comic) {
          if (mounted) {
            setState(() {
              _status = comic.status;
              _etaSeconds = _aiServerService.calculateETA(comic);
            });

            // 완료되면 결과 화면으로 이동
            if (comic.status == ComicStatus.completed) {
              _navigateToResult(comic);
            }
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _status = ComicStatus.failed;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = ComicStatus.failed;
        });
      }
    }
  }

  /// 결과 화면으로 이동
  void _navigateToResult(Comic comic) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ComicResultScreen(comic: comic),
      ),
    );
  }

  /// 재시도
  Future<void> _retry() async {
    await _startComicGeneration();
  }

  /// 취소
  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('만화 생성 중'),
        backgroundColor: const Color(0xFF00D884),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancel,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 상태별 아이콘
            _buildStatusIcon(),

            const SizedBox(height: 32),

            // 상태 메시지
            _buildStatusMessage(),

            const SizedBox(height: 24),

            // 진행률 표시
            if (_status == ComicStatus.processing) _buildProgressIndicator(),

            const SizedBox(height: 32),

            // ETA 표시
            if (_etaSeconds > 0) _buildETA(),

            const SizedBox(height: 48),

            // 액션 버튼
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (_status) {
      case ComicStatus.pending:
        return const Icon(
          Icons.hourglass_empty,
          size: 80,
          color: Color(0xFF00D884),
        );
      case ComicStatus.processing:
        return const Icon(
          Icons.auto_awesome,
          size: 80,
          color: Color(0xFF00D884),
        );
      case ComicStatus.completed:
        return const Icon(
          Icons.check_circle,
          size: 80,
          color: Colors.green,
        );
      case ComicStatus.failed:
        return const Icon(
          Icons.error,
          size: 80,
          color: Colors.red,
        );
    }
  }

  Widget _buildStatusMessage() {
    String message;
    Color color = const Color(0xFF00D884);

    switch (_status) {
      case ComicStatus.pending:
        message = '만화 생성을 준비하고 있어요...';
        break;
      case ComicStatus.processing:
        message = 'AI가 당신의 일기를 만화로 만들고 있어요!';
        break;
      case ComicStatus.completed:
        message = '만화가 완성되었어요! 🎉';
        color = Colors.green;
        break;
      case ComicStatus.failed:
        message = '만화 생성에 실패했어요 😢';
        color = Colors.red;
        break;
    }

    return Text(
      message,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        const SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D884)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'AI가 열심히 작업 중이에요...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildETA() {
    final minutes = _etaSeconds ~/ 60;
    final seconds = _etaSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00D884).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '예상 완료 시간: $minutes분 $seconds초',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF00D884),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_status == ComicStatus.failed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _retry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D884),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('다시 시도'),
          ),
          TextButton(
            onPressed: _cancel,
            child: const Text('취소'),
          ),
        ],
      );
    }

    return TextButton(
      onPressed: _cancel,
      child: const Text('취소'),
    );
  }
}
