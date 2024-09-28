class Ranking {
  final String score;
  final MemberDto member;

  Ranking({
    required this.score,
    required this.member,
  });

  // JSON 데이터 파싱해 Ranking 객체 생성
  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      score: json['score'],
      member: MemberDto.fromJson(json['memberDto']),
    );
  }
}

class MemberDto {
  final int memberId;
  final String nickname;
  final MemberImage? memberImage;

  MemberDto({
    required this.memberId,
    required this.nickname,
    this.memberImage,
  });

  // JSON 데이터를 파싱하여 MemberDto 객체 생성
  factory MemberDto.fromJson(Map<String, dynamic> json) {
    return MemberDto(
      memberId: json['memberId'],
      nickname: json['nickname'],
      memberImage: json['memberImage'] != null
          ? MemberImage.fromJson(json['memberImage'])
          : null,
    );
  }
}

class MemberImage {
  final int memberId;
  final String url;
  final String path;

  MemberImage({
    required this.memberId,
    required this.url,
    required this.path,
  });

  // JSON 데이터를 파싱하여 MemberImage 객체 생성
  factory MemberImage.fromJson(Map<String, dynamic> json) {
    return MemberImage(
      memberId: json['memberId'],
      url: json['url'],
      path: json['path'],
    );
  }
}
