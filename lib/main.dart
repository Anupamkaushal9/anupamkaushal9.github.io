import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;

void main() {
  runApp(const ModernPortfolioApp());
}

class ModernPortfolioApp extends StatelessWidget {
  const ModernPortfolioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anupam Kaushal | Portfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const PortfolioScreen(),
    );
  }
}

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final ScrollController _scrollController = ScrollController();

  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _hasError = false;
  bool _isMuted = true;

  bool _isMobile = false;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/Hey_there_I_m_the_digital_ava.mp4')
      ..initialize().then((_) {
        _videoController.setVolume(0.0);
        _videoController.setLooping(false);
        _videoController.play();
        setState(() {
          _isVideoInitialized = true;
        });
      }).catchError((error) {
        setState(() {
          _hasError = true;
        });
        debugPrint("Video Error: $error");
      });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_isVideoInitialized) return;
    if (_scrollController.offset < 100) {
      if (!_videoController.value.isPlaying &&
          _videoController.value.position >= _videoController.value.duration) {
        _videoController.seekTo(Duration.zero);
        _videoController.play();
      }
    }
  }

  void _toggleAudio() {
    setState(() {
      _isMuted = !_isMuted;
      _videoController.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $urlString");
    }
  }

  void _scrollToSection(int index) {
    final screenHeight = MediaQuery.of(context).size.height;
    double targetOffset;
    switch (index) {
      case 0:
        targetOffset = screenHeight - 80;
        break;
      case 1:
        targetOffset = screenHeight + 200;
        break;
      case 2:
        targetOffset = screenHeight + 900;
        break;
      case 3:
        targetOffset = screenHeight + 1700;
        break;
      default:
        targetOffset = 0;
    }
    _scrollController.animateTo(
      targetOffset,
      duration: 800.ms,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    _isMobile = MediaQuery.of(context).size.width < 768;
    final sidePadding = _isMobile ? 20.0 : MediaQuery.of(context).size.width * 0.15;

    return Scaffold(
      body: Stack(
        children: [
          // Background Particle Field
          const Positioned.fill(child: NeonParticleField()),
          // Floating Code Elements throughout the entire scrollable area
          _buildFloatingCodeElements(),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.black.withOpacity(0.85),
                floating: true,
                pinned: true,
                elevation: 0,
                centerTitle: false,
                title: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00F0FF), Color(0xFFFF007F)],
                  ).createShader(bounds),
                  child: Text(
                    'AK.',
                    style: GoogleFonts.oswald(
                      fontSize: _isMobile ? 22 : 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                actions: _isMobile
                    ? null
                    : [
                  _buildNavButton('ABOUT', 0),
                  _buildNavButton('EDUCATION', 1),
                  _buildNavButton('EXPERIENCE', 2),
                  _buildNavButton('PROJECTS', 3),
                  const SizedBox(width: 20),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroSection(sidePadding),
                    _buildAboutSection(sidePadding),
                    _buildEducationSkillsSection(sidePadding),
                    _buildExperienceSection(sidePadding),
                    _buildProjectsSection(sidePadding),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String title, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: TextButton(
        onPressed: () => _scrollToSection(index),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCodeElements() {
    final List<Map<String, dynamic>> codeElements = [
      {'char': '{ }', 'size': 24, 'color': const Color(0xFFFF007F), 'top': 0.1, 'left': 0.05, 'delay': 0, 'duration': 8},
      {'char': '< />', 'size': 20, 'color': const Color(0xFF00F0FF), 'top': 0.15, 'right': 0.08, 'delay': 1, 'duration': 7},
      {'char': '() =>', 'size': 18, 'color': const Color(0xFFCEFF00), 'top': 0.3, 'left': 0.1, 'delay': 2, 'duration': 9},
      {'char': 'import', 'size': 16, 'color': const Color(0xFF00FF66), 'top': 0.45, 'right': 0.12, 'delay': 0.5, 'duration': 6},
      {'char': 'class', 'size': 20, 'color': const Color(0xFFFF007F), 'top': 0.55, 'left': 0.07, 'delay': 3, 'duration': 10},
      {'char': 'Widget', 'size': 18, 'color': const Color(0xFF00F0FF), 'top': 0.7, 'right': 0.1, 'delay': 1.5, 'duration': 7},
      {'char': 'async', 'size': 16, 'color': const Color(0xFFCEFF00), 'top': 0.82, 'left': 0.12, 'delay': 2.5, 'duration': 8},
      {'char': 'await', 'size': 16, 'color': const Color(0xFFFF007F), 'top': 0.92, 'right': 0.15, 'delay': 4, 'duration': 6},
      {'char': 'final', 'size': 14, 'color': const Color(0xFF00FF66), 'top': 0.08, 'right': 0.25, 'delay': 3.5, 'duration': 5},
      {'char': 'const', 'size': 14, 'color': const Color(0xFF00F0FF), 'top': 0.22, 'left': 0.2, 'delay': 5, 'duration': 7},
      {'char': 'Widget build', 'size': 12, 'color': const Color(0xFFFF007F), 'top': 0.38, 'right': 0.2, 'delay': 4.5, 'duration': 6},
      {'char': 'Stateful', 'size': 14, 'color': const Color(0xFFCEFF00), 'top': 0.52, 'left': 0.18, 'delay': 6, 'duration': 8},
      {'char': 'setState', 'size': 12, 'color': const Color(0xFF00F0FF), 'top': 0.68, 'right': 0.22, 'delay': 2, 'duration': 5},
      {'char': 'initState', 'size': 12, 'color': const Color(0xFF00FF66), 'top': 0.78, 'left': 0.25, 'delay': 7, 'duration': 6},
      {'char': 'dispose', 'size': 12, 'color': const Color(0xFFFF007F), 'top': 0.88, 'right': 0.18, 'delay': 5.5, 'duration': 7},
      {'char': 'Future', 'size': 14, 'color': const Color(0xFFCEFF00), 'top': 0.05, 'left': 0.35, 'delay': 8, 'duration': 9},
      {'char': 'Stream', 'size': 14, 'color': const Color(0xFF00F0FF), 'top': 0.18, 'right': 0.35, 'delay': 3, 'duration': 7},
      {'char': 'Bloc', 'size': 16, 'color': const Color(0xFFFF007F), 'top': 0.32, 'left': 0.3, 'delay': 9, 'duration': 8},
      {'char': 'Provider', 'size': 12, 'color': const Color(0xFF00FF66), 'top': 0.48, 'right': 0.3, 'delay': 6.5, 'duration': 6},
      {'char': 'GetX', 'size': 14, 'color': const Color(0xFF00F0FF), 'top': 0.62, 'left': 0.28, 'delay': 4, 'duration': 7},
      {'char': 'REST API', 'size': 12, 'color': const Color(0xFFCEFF00), 'top': 0.75, 'right': 0.28, 'delay': 10, 'duration': 8},
      {'char': 'GraphQL', 'size': 12, 'color': const Color(0xFFFF007F), 'top': 0.85, 'left': 0.32, 'delay': 7.5, 'duration': 6},
    ];

    return Stack(
      children: codeElements.map((element) {
        return Positioned(
          top: element['top'] != null ? MediaQuery.of(context).size.height * element['top'] : null,
          bottom: element['bottom'] != null ? MediaQuery.of(context).size.height * element['bottom'] : null,
          left: element['left'] != null ? MediaQuery.of(context).size.width * element['left'] : null,
          right: element['right'] != null ? MediaQuery.of(context).size.width * element['right'] : null,
          child: IgnorePointer(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(seconds: element['duration']),
              builder: (context, value, child) {
                return Opacity(
                  opacity: 0.3 + (value * 0.4) * 0.3,
                  child: Transform.translate(
                    offset: Offset(0, (value * 20)* 10),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [element['color'], element['color'].withOpacity(0.5)],
                      ).createShader(bounds),
                      child: Text(
                        element['char'],
                        style: GoogleFonts.firaCode(
                          fontSize: element['size'].toDouble(),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeroSection(double sidePadding) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight,
      child: Stack(
        children: [
          // Video Background
          Positioned.fill(
            child: _hasError
                ? Container(color: Colors.black)
                : _isVideoInitialized
                ? Transform.scale(
              scale: _isMobile ? 1.3 : 1.15,
              child: Transform.translate(
                offset: Offset(_isMobile ? 120 : 80, 0),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ),
            )
                : Container(color: Colors.black),
          ),
          // Gradient overlay that fades to transparent exactly at the bottom
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Hero Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sidePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: _isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF91FCFF), Color(0xFFFF9DD3), Color(
                        0xFFEFFFB4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    _isMobile ? 'ANUPAM\nKAUSHAL' : 'ANUPAM\nKAUSHAL',
                    style: GoogleFonts.oswald(
                      fontSize: _isMobile ? 52 : 120,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      color: Colors.white,
                      shadows: [
                        const Shadow(color: Color(0xFF00F0FF), blurRadius: 30),
                        const Shadow(color: Color(0xFFFF007F), blurRadius: 50),
                      ],
                    ),
                    textAlign: _isMobile ? TextAlign.center : TextAlign.left,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.6)),
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.black.withOpacity(0.4),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.3), blurRadius: 10),
                    ],
                  ),
                  child: Text(
                    _isMobile ? 'DEVELOPER · ARCHITECT\nFLUTTER SPECIALIST' : 'DEVELOPER · ARCHITECT · FLUTTER SPECIALIST',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: Color(0xFFCEFF00),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B5).withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 8,
                    shadowColor: const Color(0xFF0077B5).withOpacity(0.8),
                  ),
                  onPressed: () => _launchURL('https://www.linkedin.com/in/anupam-kaushal-b6385719b/'),
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text(
                    'CONNECT ON LINKEDIN',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ).animate().fadeIn(delay: 400.ms),
                if (_isVideoInitialized)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: GestureDetector(
                      onTap: _toggleAudio,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.2), blurRadius: 8),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: const Color(0xFF00F0FF), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              _isMuted ? 'UNMUTE' : 'AUDIO ON',
                              style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(double sidePadding) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 60),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00F0FF), Color(0xFFFF007F)],
            ).createShader(bounds),
            child: Text(
              'ABOUT ME',
              style: GoogleFonts.oswald(
                fontSize: _isMobile ? 40 : 70,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Text(
              'Flutter developer with over 4 years of experience in designing, developing, and maintaining scalable mobile applications for Android and iOS. Expertise in application architecture, feature development, performance optimization, and UI/UX integration using Dart and the Flutter SDK.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _isMobile ? 14 : 16,
                height: 1.6,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSkillsSection(double sidePadding) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00F0FF), Color(0xFFFF007F)],
            ).createShader(bounds),
            child: Text(
              'EDUCATION',
              style: GoogleFonts.oswald(
                fontSize: _isMobile ? 32 : 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildEducationCard('MCA', 'Kamla Nehru Institute of Technology Sultanpur', 'July 2017 - June 2020', '80%'),
          const SizedBox(height: 16),
          _buildEducationCard('BCA', 'Mahatma Jyotiba Phule Rohilkhand University Bareilly', 'July 2012 - June 2015', '64%'),
          const SizedBox(height: 40),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00F0FF), Color(0xFFFF007F)],
            ).createShader(bounds),
            child: Text(
              'TECHNICAL SKILLS',
              style: GoogleFonts.oswald(
                fontSize: _isMobile ? 32 : 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Flutter SDK', 'Dart', 'Android (Java)', 'Bloc', 'GetX', 'REST APIs', 'GraphQL',
              'AWS Cloud', 'Multithreading', 'Memory Management', 'CI/CD', 'Fastlane',
              'Xcode', 'UI Testing', 'Push Notifications', 'App Store Submission'
            ].map((skill) => _buildSkillBadge(skill)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCard(String degree, String school, String duration, String score) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.1), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  degree,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00FF66), Color(0xFFCEFF00)],
                ).createShader(bounds),
                child: Text(
                  score,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(school, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text(duration, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSkillBadge(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Text(
        skill,
        style: const TextStyle(color: Color(0xFFCEFF00), fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildExperienceSection(double sidePadding) {
    final experiences = [
      {'num': '01', 'role': 'Senior Flutter Developer', 'company': 'Municipal Corporation of Delhi'},
      {'num': '02', 'role': 'Flutter Developer', 'company': 'Aeologic Technology'},
      {'num': '03', 'role': 'Flutter Developer', 'company': 'Party Hunt'},
      {'num': '04', 'role': 'Flutter Developer', 'company': 'SIT Pvt Ltd'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00F0FF), Color(0xFFFF007F)],
            ).createShader(bounds),
            child: Text(
              'EXPERIENCE',
              style: GoogleFonts.oswald(
                fontSize: _isMobile ? 40 : 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 40),
          ...experiences.map((exp) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00F0FF), Color(0xFFFF007F)],
                    ).createShader(bounds),
                    child: Text(
                      exp['num']!,
                      style: GoogleFonts.oswald(
                        fontSize: _isMobile ? 32 : 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp['role']!.toUpperCase(),
                          style: TextStyle(
                            fontSize: _isMobile ? 14 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exp['company']!,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF00F0FF), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProjectsSection(double sidePadding) {
    final projects = [
      {
        'number': '01',
        'title': 'MCD PRO',
        'tagline': 'Streamlining municipal workforce productivity.',
        'desc': 'Architected a comprehensive internal enterprise system for the Municipal Corporation of Delhi, automating attendance, task management, and performance tracking.',
        'accentColor': const Color(0xFFCEFF00),
        'logoAsset': 'assets/mcd_pro logo.png',
        'playStoreUrl': 'https://play.google.com/store/apps/details?id=com.mcd.mcd_attendance&hl=en_IN',
        'appStoreUrl': 'https://apps.apple.com/us/app/mcd-pro/id6755871807',
      },
      {
        'number': '02',
        'title': 'PARTY HUNT',
        'tagline': 'High-traffic event discovery platform.',
        'desc': 'Implemented Bloc state management to handle real-time updates, engineered multi-layered search filters, and integrated secure ticket transactions.',
        'accentColor': const Color(0xFF00E5FF),
        'logoAsset': 'assets/partyhunt_logo.png',
        'playStoreUrl': 'https://play.google.com/store/apps/details?id=com.samsara.partyhunt&hl=en_IN',
        'appStoreUrl': 'https://apps.apple.com/in/app/party-hunt-book-event-tickets/id1435981626',
      },
      {
        'number': '03',
        'title': 'MCD PARK PRO',
        'tagline': 'Smart-city parking solution.',
        'desc': 'Utilizing QR code-based systems and Paytm integration to digitize and secure municipal fee collection.',
        'accentColor': const Color(0xFFFF007A),
        'logoAsset': 'assets/mcd_park_pro logo.png',
        'playStoreUrl': 'https://play.google.com/store/apps/details?id=com.mcd.mcd_just_park&hl=en_IN',
        'appStoreUrl': 'https://apps.apple.com/in/app/mcd-park-pro/id6754152876',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00F0FF), Color(0xFFFF007F)],
            ).createShader(bounds),
            child: Text(
              'PROJECTS',
              style: GoogleFonts.oswald(
                fontSize: _isMobile ? 40 : 70,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ...projects.map((project) => Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: _buildProjectCard(project),
          )),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Container(
      padding: EdgeInsets.all(_isMobile ? 20 : 30),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (project['accentColor'] as Color).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: (project['accentColor'] as Color).withOpacity(0.15), blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [project['accentColor'] as Color, (project['accentColor'] as Color).withOpacity(0.5)],
                ).createShader(bounds),
                child: Text(
                  project['number']!,
                  style: GoogleFonts.oswald(
                    fontSize: _isMobile ? 32 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: (project['accentColor'] as Color).withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: (project['accentColor'] as Color).withOpacity(0.3), blurRadius: 8),
                  ],
                ),
                child: Text(
                  'LIVE',
                  style: TextStyle(color: project['accentColor'], fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (project['accentColor'] as Color).withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(color: (project['accentColor'] as Color).withOpacity(0.2), blurRadius: 10),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    project['logoAsset']!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.apps, color: project['accentColor'], size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  project['title']!,
                  style: GoogleFonts.oswald(
                    fontSize: _isMobile ? 28 : 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: (project['accentColor'] as Color).withOpacity(0.5), blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            project['tagline']!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: project['accentColor'],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            project['desc']!,
            style: TextStyle(fontSize: _isMobile ? 13 : 14, height: 1.5, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (project['playStoreUrl'] != null)
                _buildStoreButton(
                  icon: Icons.shop,
                  label: 'Play Store',
                  color: const Color(0xFF3DDC84),
                  onPressed: () => _launchURL(project['playStoreUrl']),
                ),
              if (project['appStoreUrl'] != null)
                _buildStoreButton(
                  icon: Icons.apple,
                  label: 'App Store',
                  color: Colors.white,
                  onPressed: () => _launchURL(project['appStoreUrl']),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.6)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.black.withOpacity(0.3),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class NeonParticleField extends StatefulWidget {
  const NeonParticleField({Key? key}) : super(key: key);

  @override
  State<NeonParticleField> createState() => _NeonParticleFieldState();
}

class _NeonParticleFieldState extends State<NeonParticleField> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 20.seconds)..repeat();
    // Generate 150 particles for a rich, dense coding atmosphere
    for (int i = 0; i < 150; i++) {
      _particles.add(_Particle(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        speed: 0.3 + math.Random().nextDouble() * 2,
        size: 1 + math.Random().nextDouble() * 4,
        colorIndex: math.Random().nextInt(4),
        shape: math.Random().nextInt(3),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: NeonParticlePainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  final double x;
  double y;
  final double speed;
  final double size;
  final int colorIndex;
  final int shape; // 0: circle, 1: square, 2: diamond

  _Particle({required this.x, required this.y, required this.speed, required this.size, required this.colorIndex, required this.shape});
}

class NeonParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;

  NeonParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final List<Color> neonColors = [
      const Color(0xFF00F0FF), // Cyan
      const Color(0xFFFF007F), // Pink
      const Color(0xFFCEFF00), // Lime
      const Color(0xFF00FF66), // Green
    ];

    for (var particle in particles) {
      double yOffset = (particle.y + animationValue * particle.speed) % 1.0 * size.height;
      double xOffset = particle.x * size.width;

      final paint = Paint()
        ..color = neonColors[particle.colorIndex % neonColors.length].withOpacity(0.12)
        ..style = PaintingStyle.fill;

      switch (particle.shape) {
        case 0: // Circle
          canvas.drawCircle(Offset(xOffset, yOffset), particle.size, paint);
          break;
        case 1: // Square
          canvas.drawRect(
            Rect.fromCenter(center: Offset(xOffset, yOffset), width: particle.size * 2, height: particle.size * 2),
            paint,
          );
          break;
        case 2: // Diamond
          final path = Path();
          final center = Offset(xOffset, yOffset);
          final s = particle.size;
          path.moveTo(center.dx, center.dy - s);
          path.lineTo(center.dx + s, center.dy);
          path.lineTo(center.dx, center.dy + s);
          path.lineTo(center.dx - s, center.dy);
          path.close();
          canvas.drawPath(path, paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}