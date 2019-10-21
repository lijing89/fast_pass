class DealBtcModelEntity {
	DealBtcModelMessage message;
	int error;
	String type;

	DealBtcModelEntity({this.message, this.error, this.type});

	DealBtcModelEntity.fromJson(Map<String, dynamic> json) {
		message = json['message'] != null ? new DealBtcModelMessage.fromJson(json['message']) : null;
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

class DealBtcModelMessage {
	DealBtcModelMessageLog log;

	DealBtcModelMessage({this.log});

	DealBtcModelMessage.fromJson(Map<String, dynamic> json) {
		log = json['log'] != null ? new DealBtcModelMessageLog.fromJson(json['log']) : null;
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		if (this.log != null) {
      data['log'] = this.log.toJson();
    }
		return data;
	}
}

class DealBtcModelMessageLog {
	List<DealBtcModelMessageLogData> data;
	String html;
	DealBtcModelMessageLogPage page;

	DealBtcModelMessageLog({this.data, this.html, this.page});

	DealBtcModelMessageLog.fromJson(Map<String, dynamic> json) {
		if (json['data'] != null) {
			data = new List<DealBtcModelMessageLogData>();(json['data'] as List).forEach((v) { data.add(new DealBtcModelMessageLogData.fromJson(v)); });
		}
		html = json['html'];
		page = json['page'] != null ? new DealBtcModelMessageLogPage.fromJson(json['page']) : null;
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

class DealBtcModelMessageLogData {
	dynamic des;
	String userId;
	String ctime;
	String id;
	String btcNum;
	String status;

	DealBtcModelMessageLogData({this.des, this.userId, this.ctime, this.id, this.btcNum, this.status});

	DealBtcModelMessageLogData.fromJson(Map<String, dynamic> json) {
		double btcNumber = double.parse(json['btc_num']);
		btcNumber = btcNumber/1000;
		btcNumber = btcNumber/1000;
		btcNumber = btcNumber/1000;
		des = json['des'];
		userId = json['user_id'];
		ctime = json['ctime'];
		id = json['id'];
		btcNum = btcNumber.toString();
		status = json['status'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['des'] = this.des;
		data['user_id'] = this.userId;
		data['ctime'] = this.ctime;
		data['id'] = this.id;
		data['btc_num'] = this.btcNum;
		data['status'] = this.status;
		return data;
	}
}

class DealBtcModelMessageLogPage {
	String total;
	int totalPage;
	int pageSize;
	int page;

	DealBtcModelMessageLogPage({this.total, this.totalPage, this.pageSize, this.page});

	DealBtcModelMessageLogPage.fromJson(Map<String, dynamic> json) {
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
