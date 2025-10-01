import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드
  try {
    await dotenv.load(fileName: "config.env");
  } catch (e) {
    // 개발 모드에서는 환경 변수 파일이 없어도 계속 진행
    // Environment file not found, continuing in development mode
  }

  // Supabase 초기화
  try {
    await SupabaseService.initialize();
  } catch (e) {
    // Supabase 초기화 실패 시에도 앱은 계속 실행
    // Initialization failed, continuing without Supabase
  }

  runApp(const WebtoonDiaryApp());
}

class WebtoonDiaryApp extends StatelessWidget {
  const WebtoonDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: '웹툰 다이어리',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00D884),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF00D884),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D884),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00D884), width: 2),
            ),
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const AuthWrapper(),
          '/home': (context) => const AuthWrapper(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
