import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

class FirestoreApplicationRepository implements ApplicationRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  @override
  Future<ApplicationEntity> submitApplication({
    required String projectId,
    required String role,
    required List<String> skills,
    String? portfolioUrl,
    required String motivation,
  }) async {
    final user = _auth.currentUser!;

    // Получаем название проекта
    final projectDoc = await _db.collection('projects').doc(projectId).get();
    final projectTitle = (projectDoc.data() as Map)['title'] ?? '';

    final ref = await _db.collection('applications').add({
      'projectId': projectId,
      'projectTitle': projectTitle,
      'applicantId': user.uid,
      'applicantName': user.displayName ?? '',
      'applicantAvatarUrl': user.photoURL,
      'role': role,
      'skills': skills,
      'portfolioUrl': portfolioUrl,
      'motivation': motivation,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return getApplicationById(ref.id);
  }

  @override
  Future<List<ApplicationEntity>> getApplicationsForProject(String projectId) async {
    final snap = await _db.collection('applications')
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<List<ApplicationEntity>> getMyApplications() async {
    final snap = await _db.collection('applications')
        .where('applicantId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<ApplicationEntity> updateApplicationStatus(
    String applicationId, ApplicationStatus status,
  ) async {
    final statusStr = status.name; // 'pending' / 'accepted' / 'rejected'
    await _db.collection('applications').doc(applicationId).update({
      'status': statusStr,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return getApplicationById(applicationId);
  }

  @override
  Future<ApplicationEntity> getApplicationById(String id) async {
    final doc = await _db.collection('applications').doc(id).get();
    return _fromDoc(doc);
  }

  ApplicationEntity _fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ApplicationEntity(
      id: doc.id,
      projectId: d['projectId'] ?? '',
      projectTitle: d['projectTitle'] ?? '',
      applicant: UserEntity(
        id: d['applicantId'] ?? '',
        name: d['applicantName'] ?? '',
        avatarUrl: d['applicantAvatarUrl'],
        skills: List<String>.from(d['skills'] ?? []),
        level: 'junior',
      ),
      role: d['role'] ?? '',
      skills: List<String>.from(d['skills'] ?? []),
      portfolioUrl: d['portfolioUrl'],
      motivation: d['motivation'] ?? '',
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == d['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}