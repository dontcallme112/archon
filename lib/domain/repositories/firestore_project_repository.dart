import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

class FirestoreProjectRepository implements ProjectRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  @override
  Future<List<ProjectEntity>> getFeedProjects({
    String? category,
    String? format,
    String? level,
    String? query,
  }) async {
    Query q = _db
        .collection('projects')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (category != null) q = q.where('category', isEqualTo: category);
    if (format != null)   q = q.where('format', isEqualTo: format);
    if (level != null)    q = q.where('level', isEqualTo: level);

    final snap = await q.get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<ProjectEntity> getProjectById(String id) async {
    final doc = await _db.collection('projects').doc(id).get();
    return _fromDoc(doc);
  }

  @override
  Future<ProjectEntity> createProject({
    required String title,
    required String shortDescription,
    required String fullDescription,
    required List<String> skills,
    required int slots,
    required String deadline,
    required String format,
    required String level,
  }) async {
    final user = _auth.currentUser!;
    final ref = await _db.collection('projects').add({
      'title': title,
      'shortDescription': shortDescription,
      'fullDescription': fullDescription,
      'requiredSkills': skills,
      'totalSlots': slots,
      'filledSlots': 0,
      'deadline': deadline,
      'format': format,
      'level': level,
      'authorId': user.uid,
      'authorName': user.displayName ?? '',
      'authorAvatar': user.photoURL,
      'category': 'Разработка',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return getProjectById(ref.id);
  }

  @override
  Future<ProjectEntity> updateProject(
      String id, Map<String, dynamic> data) async {
    await _db.collection('projects').doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return getProjectById(id);
  }

  @override
  Future<void> deleteProject(String id) =>
      _db.collection('projects').doc(id).delete();

  @override
  Future<void> toggleFavorite(String projectId) async {
    final ref = _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(projectId);
    final doc = await ref.get();
    doc.exists ? await ref.delete() : await ref.set({'projectId': projectId});
  }

  @override
  Future<List<ProjectEntity>> getFavorites() async {
    final favSnap = await _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .get();
    final ids = favSnap.docs.map((d) => d.id).toList();
    if (ids.isEmpty) return [];
    final snap = await _db
        .collection('projects')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<List<ProjectEntity>> searchProjects({
    List<String>? skills,
    String? deadline,
    String? format,
    String? level,
    int? maxSlots,
  }) async {
    Query q = _db.collection('projects').where('isActive', isEqualTo: true);
    if (format != null) q = q.where('format', isEqualTo: format);
    if (level != null)  q = q.where('level', isEqualTo: level);
    final snap = await q.get();
    return snap.docs.map(_fromDoc).toList();
  }

  ProjectEntity _fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProjectEntity(
      id: doc.id,
      title: d['title'] ?? '',
      shortDescription: d['shortDescription'] ?? '',
      fullDescription: d['fullDescription'] ?? '',
      requiredSkills: List<String>.from(d['requiredSkills'] ?? []),
      deadline: d['deadline'] ?? '',
      format: d['format'] ?? 'Онлайн',
      level: d['level'] ?? 'junior',
      totalSlots: d['totalSlots'] ?? 0,
      filledSlots: d['filledSlots'] ?? 0,
      author: UserEntity(
        id: d['authorId'] ?? '',
        name: d['authorName'] ?? '',
        avatarUrl: d['authorAvatar'],
        skills: [],
        level: 'junior',
      ),
      teamMembers: [],
      category: d['category'] ?? 'Разработка',
      isActive: d['isActive'] ?? true,
      createdAt:
          (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}