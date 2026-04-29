import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../../core/reference/app_reference_data.dart';

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
    int offset = 0,
    int limit = 10,
  }) async {
    final fsCategory = AppCategories.toFirestore(category);
    final fsFormat   = AppFormats.toFirestore(format);
    final fsLevel    = AppLevels.toFirestore(level);

    final hasFilters = fsCategory != null || fsFormat != null || fsLevel != null;

    Query q = _db
        .collection('projects')
        .where('isActive', isEqualTo: true);

    // orderBy только без фильтров — иначе Firestore требует составной индекс
    if (!hasFilters) {
      q = q.orderBy('createdAt', descending: true);
    }

    if (fsCategory != null) q = q.where('category', isEqualTo: fsCategory);
    if (fsFormat   != null) q = q.where('format',   isEqualTo: fsFormat);
    if (fsLevel    != null) q = q.where('level',    isEqualTo: fsLevel);

    final snap = await q.get();
    var projects = snap.docs.map(_fromDoc).toList();

    // Сортируем вручную при фильтрации
    if (hasFilters) {
      projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    // Поиск по тексту (client-side)
    if (query != null && query.isNotEmpty) {
      final lq = query.toLowerCase();
      projects = projects
          .where((p) =>
              p.title.toLowerCase().contains(lq) ||
              p.shortDescription.toLowerCase().contains(lq))
          .toList();
    }

    // Пагинация (client-side)
    if (offset >= projects.length) return [];
    return projects.skip(offset).take(limit).toList();
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
    required String category,
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
      'category': category,
      'authorId': user.uid,
      'authorName': user.displayName ?? '',
      'authorAvatar': user.photoURL,
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
    if (level  != null) q = q.where('level',  isEqualTo: level);
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
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}