class DealUssModelEntity {
	DealUssModelMessage message;
	int error;
	String type;

	DealUssModelEntity({this.message, this.error, this.type});

	DealUssModelEntity.fromJson(Map<String, dynamic> json) {
		message = json['message'] != null ? new DealUssModelMessage.fromJson(json['message']) : null;
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

class DealUssModelMessage {
	DealUssModelMessageLog log;

	DealUssModelMessage({this.log});

	DealUssModelMessage.fromJson(Map<String, dynamic> json) {
		log = json['log'] != null ? new DealUssModelMessageLog.fromJson(json['log']) : null;
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		if (this.log != null) {
      data['log'] = this.log.toJson();
    }
		return data;
	}
}

class DealUssModelMessageLog {
	List<DealUssModelMessageLogData> data;
	String html;
	DealUssModelMessageLogPage page;

	DealUssModelMessageLog({this.data, this.html, this.page});

	DealUssModelMessageLog.fromJson(Map<String, dynamic> json) {
		if (json['data'] != null) {
			data = new List<DealUssModelMessageLogData>();(json['data'] as List).forEach((v) { data.add(new DealUssModelMessageLogData.fromJson(v)); });
		}
		html = json['html'];
		page = json['page'] != null ? new DealUssModelMessageLogPage.fromJson(json['page']) : null;
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

class DealUssModelMessageLogData {
	String freeUss;//
	String ussPrice;
	String freeTime;
	String id;
	String bitPrice;
	String freeBtc;

	DealUssModelMessageLogData({this.freeUss, this.ussPrice, this.freeTime, this.id, this.bitPrice, this.freeBtc});

	DealUssModelMessageLogData.fromJson(Map<String, dynamic> json) {
		double btcNum = double.parse(json['free_btc']);
		btcNum = btcNum/1000;
		btcNum = btcNum/1000;
		btcNum = btcNum/1000;
		freeUss = json['free_uss'];
		ussPrice = json['uss_price'];
		freeTime = json['free_time'];
		id = json['id'];
		bitPrice = json['bit_price'];
		freeBtc = btcNum.toString();
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['free_uss'] = this.freeUss;
		data['uss_price'] = this.ussPrice;
		data['free_time'] = this.freeTime;
		data['id'] = this.id;
		data['bit_price'] = this.bitPrice;
		data['free_btc'] = this.freeBtc;
		return data;
	}
}

class DealUssModelMessageLogPage {
	String total;
	int totalPage;
	int pageSize;
	int page;

	DealUssModelMessageLogPage({this.total, this.totalPage, this.pageSize, this.page});

	DealUssModelMessageLogPage.fromJson(Map<String, dynamic> json) {
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
