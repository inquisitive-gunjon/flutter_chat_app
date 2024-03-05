class ChatRoom {
  ChatRoom({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.isGroup,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.phone,
    required this.members,
    required this.pushToken,
  });
  late String image;
  late String about;
  late String name;
  late String createdAt;
  late bool isOnline;
  late bool isGroup;
  late String id;
  late String lastActive;
  late String email;
  late String phone;
  late List<dynamic> members;
  late String pushToken;

  ChatRoom.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? '';
    isGroup = json['is_group'] ?? '';
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
    phone = json['phone'] ?? '';
    members = json['members'] ?? '';
    pushToken = json['push_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['is_group'] = isGroup;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['phone'] = phone;
    data['members'] = members;
    data['push_token'] = pushToken;
    return data;
  }
}
