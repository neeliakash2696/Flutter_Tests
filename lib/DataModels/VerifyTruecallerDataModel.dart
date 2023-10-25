class VerifyTruecallerDataMode {
  final Response response;

  VerifyTruecallerDataMode({
    required this.response
  });

  factory VerifyTruecallerDataMode.fromJson(Map<String, dynamic> json) {
    return VerifyTruecallerDataMode(
      response: Response.fromJson(json['Response']),
    );
  }
}

class Response {
  final String code;
  final String status;
  final String message;
  final LoginData? loginData;

  Response({
    required this.code,
    required this.status,
    required this.message,
    required this.loginData,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    var loginDataJson = json['LOGIN_DATA'];
    var codeCheck=json['Code'];
    print("loginDataJson=$codeCheck");
    return Response(
      code: json['Code']??"",
      status: json['Status']??"",
      message: json['Message']??"",
      loginData: codeCheck=="200"
          ? LoginData.fromJson(loginDataJson)
          : null,
    );
  }
}

class LoginData {
  final DataCookie dataCookie;
  final LoginCookie loginCookie;
  final ImIss imIss;
  final String glid;
  final int access;
  final int time;

  LoginData({
    required this.dataCookie,
    required this.loginCookie,
    required this.imIss,
    required this.glid,
    required this.access,
    required this.time,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    print("imss=${ImIss.fromJson(json['im_iss'])}");
    return LoginData(
      dataCookie: DataCookie.fromJson(json['DataCookie']),
      loginCookie: LoginCookie.fromJson(json['LoginCookie']),
      imIss: ImIss.fromJson(json['im_iss']),
      glid: json['glid']??'',
      access: json['access']??'',
      time: json['time']??'',
    );
  }
}

class DataCookie {
  final String fn;
  final String em;
  final String phcc;
  final String iso;
  final String mb1;
  final String ctid;
  final String glid;
  final String cd;
  final String cmid;
  final String utyp;
  final String ev;
  final String uv;
  final String usts;
  final String admln;
  final int admsales;

  DataCookie({
    required this.fn,
    required this.em,
    required this.phcc,
    required this.iso,
    required this.mb1,
    required this.ctid,
    required this.glid,
    required this.cd,
    required this.cmid,
    required this.utyp,
    required this.ev,
    required this.uv,
    required this.usts,
    required this.admln,
    required this.admsales,
  });

  factory DataCookie.fromJson(Map<String, dynamic> json) {
    return DataCookie(
      fn: json['fn']??'',
      em: json['em']??'',
      phcc: json['phcc']??'',
      iso: json['iso']??'',
      mb1: json['mb1']??'',
      ctid: json['ctid']??'',
      glid: json['glid']??'',
      cd: json['cd']??'',
      cmid: json['cmid']??'',
      utyp: json['utyp']??'',
      ev: json['ev']??'',
      uv: json['uv']??'',
      usts: json['usts']??'',
      admln: json['admln']??'',
      admsales: json['admsales']??'',
    );
  }
}

class LoginCookie {
  final String id;
  final String admln;
  final int admsales;
  final String au;
  final String vcd;

  LoginCookie({
    required this.id,
    required this.admln,
    required this.admsales,
    required this.au,
    required this.vcd,
  });

  factory LoginCookie.fromJson(Map<String, dynamic> json) {
    return LoginCookie(
      id: json['id']??'',
      admln: json['admln']??'',
      admsales: json['admsales']??0,
      au: json['au']??'',
      vcd: json['vcd']??'',
    );
  }
}

class ImIss {
  final String AK;

  ImIss({
    required this.AK,
  });

  factory ImIss.fromJson(Map<String, dynamic> json) {
    return ImIss(
      AK: json['t']??'',
    );
  }
}