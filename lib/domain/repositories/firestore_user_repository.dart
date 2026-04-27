import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

class FirestoreUserRepository implements UserRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Геттер для безопасного получения UID
  String? get _uid => _auth.currentUser?.uid;

  // Исправлено: теперь принимает опциональное имя для первичной регистрации
  Future<void> ensureUserExists({String? name}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _db.collection('users').doc(user.uid).get();
    
    if (!doc.exists) {
      await _db.collection('users').doc(user.uid).set({
        'id': user.uid,
        'name': name ?? user.displayName ?? 'Новый пользователь',
        'email': user.email ?? '',
        'avatarUrl': user.photoURL,
        'telegram': null,
        'skills': [],
        'level': 'junior',
        'portfolioUrl': null,
        'bio': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Стрим для прослушивания данных профиля в реальном времени
  Stream<UserEntity?> userStream() {
    if (_uid == null) return Stream.value(null);
    return _db.collection('users').doc(_uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _userFromDoc(doc);
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    if (_uid == null) return null;
    final doc = await _db.collection('users').doc(_uid!).get();
    if (!doc.exists) return null;
    return _userFromDoc(doc);
  }

  @override
  Future<UserEntity> updateProfile({
    required List<String> skills,
    required String level,
    String? portfolioUrl,
    String? bio,
    String? telegram,
  }) async {
    if (_uid == null) throw Exception('User not authenticated');
    
    await _db.collection('users').doc(_uid).update({
      'skills': skills,
      'level': level,
      'portfolioUrl': portfolioUrl,
      'bio': bio,
      'telegram': telegram,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return (await getCurrentUser())!;
  }

  @override
  Future<List<ProjectEntity>> getMyProjects() async {
    if (_uid == null) return [];
    final snap = await _db
        .collection('projects')
        .where('authorId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(_projectFromDoc).toList();
  }

  UserEntity _userFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserEntity(
      id: doc.id,
      name: d['name'] ?? '',
      avatarUrl: d['avatarUrl'],
      telegram: d['telegram'],
      skills: List<String>.from(d['skills'] ?? []),
      level: d['level'] ?? 'junior',
      portfolioUrl: d['portfolioUrl'],
      bio: d['bio'],
    );
  }

  ProjectEntity _projectFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProjectEntity(
      id: doc.id,
      title: d['title'] ?? '',
      shortDescription: d['shortDescription'] ?? '',
      fullDescription: d['fullDescription'] ?? '',
      requiredSkills: List<String>.from(d['requiredSkills'] ?? []),
      deadline: d['deadline'] ?? '',
      format: d['format'] ?? 'online',
      level: d['level'] ?? 'junior',
      totalSlots: d['totalSlots'] ?? 0,
      filledSlots: d['filledSlots'] ?? 0,
      author: UserEntity(
        id: d['authorId'] ?? '',
        name: d['authorName'] ?? '',
        avatarUrl: d['authorAvatarUrl'],
        skills: [],
        level: 'junior',
      ),
      teamMembers: [],
      category: d['category'] ?? 'dev',
      isActive: d['isActive'] ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}