class MyTeamEntity {
	MyTeamMessage message;
	int error;
	String type;

	MyTeamEntity({this.message, this.error, this.type});

	MyTeamEntity.fromJson(Map<String, dynamic> json) {
		message = json['message'] != null ? new MyTeamMessage.fromJson(json['message']) : null;
		error = json['error'];
		type = json['type'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		if (this.message != null) {
      data['message'] = this.message.toJson();
    }
		data['error'] = this.error;
		data['type'] = this.type;
		return data;
	}
}

class MyTeamMessage {
	dynamic grade;
	MyTeamMessageList xList;

	MyTeamMessage({this.grade, this.xList});

	MyTeamMessage.fromJson(Map<String, dynamic> json) {
		grade = json['grade'];
		xList = json['list'] != null ? new MyTeamMessageList.fromJson(json['list']) : null;
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		if (this.grade != null) {
      data['grade'] = this.grade.toJson();
    }
		if (this.xList != null) {
      data['list'] = this.xList.toJson();
    }
		return data;
	}
}

//class MyTeamMessageGrade {
//	String 1;
//	String 2;
//
//	MyTeamMessageGrade({this.1, this.2});
//
//	MyTeamMessageGrade.fromJson(Map<String, dynamic> json) {
//		1 = json['1'];
//		2 = json['2'];
//	}
//
//	Map<String, dynamic> toJson() {
//		final Map<String, dynamic> data = new Map<String, dynamic>();
//		data['1'] = this.1;
//		data['2'] = this.2;
//		return data;
//	}
//}

class MyTeamMessageList {
	List<MyTeamMessageListData> data;
	String html;
	MyTeamMessageListPage page;

	MyTeamMessageList({this.data, this.html, this.page});

	MyTeamMessageList.fromJson(Map<String, dynamic> json) {
		if (json['data'] != null) {
			data = new List<MyTeamMessageListData>();(json['data'] as List).forEach((v) { data.add(new MyTeamMessageListData.fromJson(v)); });
		}
		html = json['html'];
		page = json['page'] != null ? new MyTeamMessageListPage.fromJson(json['page']) : null;
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		if (this.data != null) {
      data['data'] =  this.data.map((v) => v.toJson()).toList();
    }
		data['html'] = this.html;
		if (this.page != null) {
      data['page'] = this.page.toJson();
    }
		return data;
	}
}

class MyTeamMessageListData {
	String password;
	String validcode;
	String groupId;
	String regTime;
	String name;
	dynamic headPic;
	String mobile;
	String realName;
	String id;
	String email;
	String recUid;
	String status;

	MyTeamMessageListData({this.password, this.validcode, this.groupId, this.regTime, this.name, this.headPic, this.mobile, this.realName, this.id, this.email, this.recUid, this.status});

	MyTeamMessageListData.fromJson(Map<String, dynamic> json) {
		password = json['password'];
		validcode = json['validcode'];
		groupId = json['group_id'];
		regTime = json['reg_time'];
		name = json['name'];
		headPic = json['head_pic'];
		mobile = json['mobile'];
		realName = json['real_name'];
		id = json['id'];
		email = json['email'];
		recUid = json['rec_uid'];
		status = json['status'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['password'] = this.password;
		data['validcode'] = this.validcode;
		data['group_id'] = this.groupId;
		data['reg_time'] = this.regTime;
		data['name'] = this.name;
		data['head_pic'] = this.headPic;
		data['mobile'] = this.mobile;
		data['real_name'] = this.realName;
		data['id'] = this.id;
		data['email'] = this.email;
		data['rec_uid'] = this.recUid;
		data['status'] = this.status;
		return data;
	}
}

class MyTeamMessageListPage {
	String total;
	int totalPage;
	int pageSize;
	int page;

	MyTeamMessageListPage({this.total, this.totalPage, this.pageSize, this.page});

	MyTeamMessageListPage.fromJson(Map<String, dynamic> json) {
		total = json['total'];
		totalPage = json['totalPage'];
		pageSize = json['pageSize'];
		page = json['page'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['total'] = this.total;
		data['totalPage'] = this.totalPage;
		data['pageSize'] = this.pageSize;
		data['page'] = this.page;
		return data;
	}
}
