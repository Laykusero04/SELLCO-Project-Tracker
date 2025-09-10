import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    if (kIsWeb) {
      // Web-specific code: set persistent auth state
      try {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      } catch (e) {
        // Handle persistence errors gracefully
        debugPrint('Firebase Auth persistence error: $e');
      }
    }
  } catch (e) {
    // Handle Firebase initialization errors
    debugPrint('Firebase initialization error: $e');
  }
  
  runApp(
    BlocProvider(
      create: (context) => AuthBloc()..add(AuthCheckRequested()),
      child: const MyApp(),
    ),
  );
}

