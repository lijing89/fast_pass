class MyInfo {
    Message message;
    int error;
    String type;

    MyInfo({this.message, this.error, this.type});

    MyInfo.fromJson(Map<String, dynamic> json) {
        message =
        json['message'] != String ? new Message.fromJson(json['message']) : String;
        error = json['error'];
        type = json['type'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        if (this.message != String) {
            data['message'] = this.message.toJson();
        }
        data['error'] = this.error;
        data['type'] = this.type;
        return data;
    }
}

class Message {
    String userId;
    String realName;
    String phone;
    String mobile;
    String province;
    String city;
    String county;
    String addr;
    String qq;
    String sex;
    String birthday;
    String groupId;
    String point;
    String messageIds;
    String prop;
    String balance;
    String custom;
    String regTime;
    String loginTime;
    String checkinTime;
    String mobileVerified;
    String emailVerified;
    String payPasswordOpen;
    String payPassword;
    String payValidcode;
    String agentProvince;
    String agentCity;
    String agentCounty;
    String areaLv;
    String agentLevel;
    String teamNum;
    String totals;
    String isWine;
    String bonusRec;
    String bonusSrec;
    String bonusShare;
    String bonusKing;
    String bonusLeague;
    String bonusMerchant;
    String tax;
    String drecWine;
    String drecLeague;
    String teamPerf;
    String openId;
    String ussOne;
    String ussTwo;
    String bitFree;
    String ussOut;
    String nextFree;
    String myBonus;
    String teamBonus;
    String userKeep;
    String isRecive;
    String beforeCard;
    String afterCard;
    String photoCard;
    String rz;
    String idcard;
    String email;
    String name;
    String gname;
    String agentAddr;
    String agentLv;
    String con;
    String act;
    String headPic;

    Message(
        {this.userId,
            this.realName,
            this.phone,
            this.mobile,
            this.province,
            this.city,
            this.county,
            this.addr,
            this.qq,
            this.sex,
            this.birthday,
            this.groupId,
            this.point,
            this.messageIds,
            this.prop,
            this.balance,
            this.custom,
            this.regTime,
            this.loginTime,
            this.checkinTime,
            this.mobileVerified,
            this.emailVerified,
            this.payPasswordOpen,
            this.payPassword,
            this.payValidcode,
            this.agentProvince,
            this.agentCity,
            this.agentCounty,
            this.areaLv,
            this.agentLevel,
            this.teamNum,
            this.totals,
            this.isWine,
            this.bonusRec,
            this.bonusSrec,
            this.bonusShare,
            this.bonusKing,
            this.bonusLeague,
            this.bonusMerchant,
            this.tax,
            this.drecWine,
            this.drecLeague,
            this.teamPerf,
            this.openId,
            this.ussOne,
            this.ussTwo,
            this.bitFree,
            this.ussOut,
            this.nextFree,
            this.myBonus,
            this.teamBonus,
            this.userKeep,
            this.isRecive,
            this.beforeCard,
            this.afterCard,
            this.photoCard,
            this.rz,
            this.idcard,
            this.email,
            this.name,
            this.gname,
            this.agentAddr,
            this.agentLv,
            this.con,
            this.act,
            this.headPic});

    Message.fromJson(Map<String, dynamic> json) {
        userId = json['user_id'];
        realName = json['real_name'];
        phone = json['phone'];
        mobile = json['mobile'];
        province = json['province'];
        city = json['city'];
        county = json['county'];
        addr = json['addr'];
        qq = json['qq'];
        sex = json['sex'];
        birthday = json['birthday'];
        groupId = json['group_id'];
        point = json['point'];
        messageIds = json['message_ids'];
        prop = json['prop'];
        balance = json['balance'];
        custom = json['custom'];
        regTime = json['reg_time'];
        loginTime = json['login_time'];
        checkinTime = json['checkin_time'];
        mobileVerified = json['mobile_verified'];
        emailVerified = json['email_verified'];
        payPasswordOpen = json['pay_password_open'];
        payPassword = json['pay_password'];
        payValidcode = json['pay_validcode'];
        agentProvince = json['agent_province'];
        agentCity = json['agent_city'];
        agentCounty = json['agent_county'];
        areaLv = json['area_lv'];
        agentLevel = json['agent_level'];
        teamNum = json['team_num'];
        totals = json['totals'];
        isWine = json['is_wine'];
        bonusRec = json['bonus_rec'];
        bonusSrec = json['bonus_srec'];
        bonusShare = json['bonus_share'];
        bonusKing = json['bonus_king'];
        bonusLeague = json['bonus_league'];
        bonusMerchant = json['bonus_merchant'];
        tax = json['tax'];
        drecWine = json['drec_wine'];
        drecLeague = json['drec_league'];
        teamPerf = json['teamPerf'];
        openId = json['open_id'];
        ussOne = json['uss_one'];
        ussTwo = json['uss_two'];
        bitFree = json['bit_free'];
        ussOut = json['uss_out'];
        nextFree = json['next_free'];
        myBonus = json['my_bonus'];
        teamBonus = json['team_bonus'];
        userKeep = json['user_keep'];
        isRecive = json['is_recive'];
        beforeCard = json['before_card'];
        afterCard = json['after_card'];
        photoCard = json['photo_card'];
        rz = json['rz'];
        idcard = json['idcard'];
        email = json['email'];
        name = json['name'];
        gname = json['gname'];
        agentAddr = json['agent_addr'];
        agentLv = json['agent_lv'];
        con = json['con'];
        act = json['act'];
        headPic = json['head_pic'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['user_id'] = this.userId;
        data['real_name'] = this.realName;
        data['phone'] = this.phone;
        data['mobile'] = this.mobile;
        data['province'] = this.province;
        data['city'] = this.city;
        data['county'] = this.county;
        data['addr'] = this.addr;
        data['qq'] = this.qq;
        data['sex'] = this.sex;
        data['birthday'] = this.birthday;
        data['group_id'] = this.groupId;
        data['point'] = this.point;
        data['message_ids'] = this.messageIds;
        data['prop'] = this.prop;
        data['balance'] = this.balance;
        data['custom'] = this.custom;
        data['reg_time'] = this.regTime;
        data['login_time'] = this.loginTime;
        data['checkin_time'] = this.checkinTime;
        data['mobile_verified'] = this.mobileVerified;
        data['email_verified'] = this.emailVerified;
        data['pay_password_open'] = this.payPasswordOpen;
        data['pay_password'] = this.payPassword;
        data['pay_validcode'] = this.payValidcode;
        data['agent_province'] = this.agentProvince;
        data['agent_city'] = this.agentCity;
        data['agent_county'] = this.agentCounty;
        data['area_lv'] = this.areaLv;
        data['agent_level'] = this.agentLevel;
        data['team_num'] = this.teamNum;
        data['totals'] = this.totals;
        data['is_wine'] = this.isWine;
        data['bonus_rec'] = this.bonusRec;
        data['bonus_srec'] = this.bonusSrec;
        data['bonus_share'] = this.bonusShare;
        data['bonus_king'] = this.bonusKing;
        data['bonus_league'] = this.bonusLeague;
        data['bonus_merchant'] = this.bonusMerchant;
        data['tax'] = this.tax;
        data['drec_wine'] = this.drecWine;
        data['drec_league'] = this.drecLeague;
        data['teamPerf'] = this.teamPerf;
        data['open_id'] = this.openId;
        data['uss_one'] = this.ussOne;
        data['uss_two'] = this.ussTwo;
        data['bit_free'] = this.bitFree;
        data['uss_out'] = this.ussOut;
        data['next_free'] = this.nextFree;
        data['my_bonus'] = this.myBonus;
        data['team_bonus'] = this.teamBonus;
        data['user_keep'] = this.userKeep;
        data['is_recive'] = this.isRecive;
        data['before_card'] = this.beforeCard;
        data['after_card'] = this.afterCard;
        data['photo_card'] = this.photoCard;
        data['rz'] = this.rz;
        data['idcard'] = this.idcard;
        data['email'] = this.email;
        data['name'] = this.name;
        data['gname'] = this.gname;
        data['agent_addr'] = this.agentAddr;
        data['agent_lv'] = this.agentLv;
        data['con'] = this.con;
        data['act'] = this.act;
        data['head_pic'] = this.headPic;
        return data;
    }
}
