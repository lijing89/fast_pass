class AssetsModelEntity {
	AssetsModelMessage message;
	String error;
	String type;

	AssetsModelEntity({this.message, this.error, this.type});

	AssetsModelEntity.fromJson(Map<String, dynamic> json) {
		message = json['message'] != null ? new AssetsModelMessage.fromJson(json['message']) : null;
		error = json['error'].toString();
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

class AssetsModelMessage {
	String btc;
	String ussOut;
	String btcPrice;
	String ussTwo;
	String ussPrice;
	String ussOne;
	String address;
	String big;

	AssetsModelMessage({this.btc, this.ussOut, this.btcPrice, this.ussTwo, this.ussPrice, this.ussOne,this.address,this.big});

	AssetsModelMessage.fromJson(Map<String, dynamic> json) {
		btc = json['btc'].toString();
		ussOut = json['uss_out'].toString();
		btcPrice = json['btc_price'].toString();
		ussTwo = json['uss_two'].toString();
		ussPrice = json['uss_price'].toString();
		ussOne = json['uss_one'].toString();
		address = json['address'].toString();
		big = json['big'].toString();
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['btc'] = this.btc;
		data['uss_out'] = this.ussOut;
		data['btc_price'] = this.btcPrice;
		data['uss_two'] = this.ussTwo;
		data['uss_price'] = this.ussPrice;
		data['uss_one'] = this.ussOne;
		data['address'] = this.address;
		data['big'] = this.big;
		return data;
	}
}
