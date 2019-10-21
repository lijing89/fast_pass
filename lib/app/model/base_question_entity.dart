class BaseQuestionEntity {
	BaseQuestionMessage message;
	int error;
	String type;

	BaseQuestionEntity({this.message, this.error, this.type});

	BaseQuestionEntity.fromJson(Map<String, dynamic> json) {
		message = json['message'] != null ? new BaseQuestionMessage.fromJson(json['message']) : null;
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

class BaseQuestionMessage {
	String summary;
	String categoryId;
	String top;
	String publishTime;
	String count;
	String id;
	String title;
	String content;
	String status;

	BaseQuestionMessage({this.summary, this.categoryId, this.top, this.publishTime, this.count, this.id, this.title, this.content, this.status});

	BaseQuestionMessage.fromJson(Map<String, dynamic> json) {
		summary = json['summary'];
		categoryId = json['category_id'];
		top = json['top'];
		publishTime = json['publish_time'];
		count = json['count'];
		id = json['id'];
		title = json['title'];
		content = json['content'];
		status = json['status'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['summary'] = this.summary;
		data['category_id'] = this.categoryId;
		data['top'] = this.top;
		data['publish_time'] = this.publishTime;
		data['count'] = this.count;
		data['id'] = this.id;
		data['title'] = this.title;
		data['content'] = this.content;
		data['status'] = this.status;
		return data;
	}
}
