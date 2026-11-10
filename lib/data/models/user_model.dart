class AppUser {
  final String id;
  final String name;
  final String email;
  final int targetSavings;
  final bool reminderEnabled;
  final String reminderTime;
  final String reminderTimezone;
  final String? avatarUrl;
  final bool isTrial;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.targetSavings = 0,
    this.reminderEnabled = false,
    this.reminderTime = '08:00',
    this.reminderTimezone = 'Asia/Jakarta',
    this.avatarUrl,
    this.isTrial = true,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    int? targetSavings,
    bool? reminderEnabled,
    String? reminderTime,
    String? reminderTimezone,
    String? avatarUrl,
    bool? isTrial,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      targetSavings: targetSavings ?? this.targetSavings,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderTimezone: reminderTimezone ?? this.reminderTimezone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isTrial: isTrial ?? this.isTrial,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'targetSavings': targetSavings,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'reminderTimezone': reminderTimezone,
      'avatarUrl': avatarUrl,
      'isTrial': isTrial,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? 'user_1',
      name: json['name'] as String? ?? 'Pengguna SmartFi',
      email: json['email'] as String? ?? 'pengguna@smartfi.com',
      targetSavings: (json['targetSavings'] as num?)?.toInt() ?? 0,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderTime: json['reminderTime'] as String? ?? '08:00',
      reminderTimezone: json['reminderTimezone'] as String? ?? 'Asia/Jakarta',
      avatarUrl: json['avatarUrl'] as String?,
      isTrial: json['isTrial'] as bool? ?? true,
    );
  }
}

