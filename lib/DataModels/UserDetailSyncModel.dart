class UDS {
  String code;
  String execution;
  String add1;
  String add2;
  String bizType;
  String ceoFname;
  String ceoLname;
  String ceoSalute;
  String city;
  String cityStateZip;
  var cityId;
  String companyName;
  String contactAddress;
  String country;
  String countryIso;
  String date;
  String designation;
  String email1;
  String email2;
  String email3;
  String email4;
  String emailVerified;
  String fax1;
  String fax2;
  var fcpFlag;
  String firstName;
  var fkGlLegalStatusId;
  String fkGlusrBizIds;
  String fkGlusrNoofEmpId;
  String fkGlusrTurnoverId;
  String fkGlusrUsrPbizId;
  String freeshowroomAliasIm;
  String glid;
  String glusrDisabledReason;
  String glusrListingStatusReason;
  String glusrUsrAltMobileCountry;
  String glusrUsrApprov;
  String glusrUsrCompanyDesc;
  var glusrUsrCusttypeId;
  String glusrUsrCusttypeName;
  var glusrUsrCusttypeWeight;
  String glusrUsrDistrict;
  String glusrUsrFax2Area;
  String glusrUsrFax2Country;
  String glusrUsrFax2Number;
  String glusrUsrFaxArea;
  String glusrUsrFaxCountry;
  String glusrUsrFaxNumber;
  String glusrUsrLatitude;
  String glusrUsrListingStatus;
  String glusrUsrLongitude;
  var glusrUsrMembersince;
  String glusrUsrMobileCountry;
  String glusrUsrPh2Area;
  String glusrUsrPh2Country;
  String glusrUsrPh2Number;
  String glusrUsrPhArea;
  String glusrUsrPhCountry;
  String glusrUsrPhMobile;
  String glusrUsrPhMobileAlt;
  String glusrUsrPhNumber;
  String glusrUsrSellinterest;
  String glusrUsrYearOfEstb;
  String iilPerfEncryptGlusid;
  String image;
  String imageStatus;
  var isCatalog;
  String isPaid;
  String landmark;
  String lastName;
  String locality;
  var locationPreference;
  String locationSetby;
  String locationSetdate;
  String locationUpdateddate;
  String mobile1;
  String mobile2;
  String mobile3;
  String mobile4;
  String mobileVerified;
  String paidurl;
  String pnsNo;
  String pnsRatio;
  String salute;
  String showPscFlag;
  String state;
  var stateId;
  String telephone1;
  String telephone2;
  String telephone3;
  String telephone4;
  String turnover;
  String uniqueId;
  var verifiedBusinessBuyerFlag;
  String website;
  String zip;

  UDS({
    required this.code,
    required this.execution,
    required this.add1,
    required this.add2,
    required this.bizType,
    required this.ceoFname,
    required this.ceoLname,
    required this.ceoSalute,
    required this.city,
    required this.cityStateZip,
    required this.cityId,
    required this.companyName,
    required this.contactAddress,
    required this.country,
    required this.countryIso,
    required this.date,
    required this.designation,
    required this.email1,
    required this.email2,
    required this.email3,
    required this.email4,
    required this.emailVerified,
    required this.fax1,
    required this.fax2,
    required this.fcpFlag,
    required this.firstName,
    required this.fkGlLegalStatusId,
    required this.fkGlusrBizIds,
    required this.fkGlusrNoofEmpId,
    required this.fkGlusrTurnoverId,
    required this.fkGlusrUsrPbizId,
    required this.freeshowroomAliasIm,
    required this.glid,
    required this.glusrDisabledReason,
    required this.glusrListingStatusReason,
    required this.glusrUsrAltMobileCountry,
    required this.glusrUsrApprov,
    required this.glusrUsrCompanyDesc,
    required this.glusrUsrCusttypeId,
    required this.glusrUsrCusttypeName,
    required this.glusrUsrCusttypeWeight,
    required this.glusrUsrDistrict,
    required this.glusrUsrFax2Area,
    required this.glusrUsrFax2Country,
    required this.glusrUsrFax2Number,
    required this.glusrUsrFaxArea,
    required this.glusrUsrFaxCountry,
    required this.glusrUsrFaxNumber,
    required this.glusrUsrLatitude,
    required this.glusrUsrListingStatus,
    required this.glusrUsrLongitude,
    required this.glusrUsrMembersince,
    required this.glusrUsrMobileCountry,
    required this.glusrUsrPh2Area,
    required this.glusrUsrPh2Country,
    required this.glusrUsrPh2Number,
    required this.glusrUsrPhArea,
    required this.glusrUsrPhCountry,
    required this.glusrUsrPhMobile,
    required this.glusrUsrPhMobileAlt,
    required this.glusrUsrPhNumber,
    required this.glusrUsrSellinterest,
    required this.glusrUsrYearOfEstb,
    required this.iilPerfEncryptGlusid,
    required this.image,
    required this.imageStatus,
    required this.isCatalog,
    required this.isPaid,
    required this.landmark,
    required this.lastName,
    required this.locality,
    required this.locationPreference,
    required this.locationSetby,
    required this.locationSetdate,
    required this.locationUpdateddate,
    required this.mobile1,
    required this.mobile2,
    required this.mobile3,
    required this.mobile4,
    required this.mobileVerified,
    required this.paidurl,
    required this.pnsNo,
    required this.pnsRatio,
    required this.salute,
    required this.showPscFlag,
    required this.state,
    required this.stateId,
    required this.telephone1,
    required this.telephone2,
    required this.telephone3,
    required this.telephone4,
    required this.turnover,
    required this.uniqueId,
    required this.verifiedBusinessBuyerFlag,
    required this.website,
    required this.zip,
  });
  factory UDS.fromJson(Map<String, dynamic> json) {
    return UDS(
      code: json['CODE'] ?? '',
      execution : json['Execution'] ?? '',
        add1 : json['add1'] ?? '',
        add2 : json['add2'] ?? '',
        bizType : json['biz_type'] ?? '',
        ceoFname : json['ceo_fname'] ?? '',
        ceoLname : json['ceo_lname'] ?? '',
        ceoSalute : json['ceo_salute'] ?? '',
        city : json['city'] ?? '',
        cityStateZip : json['city_state_zip'] ?? '',
        cityId: json['cityid'],
        companyName : json['company_name'] ?? '',
        contactAddress : json['contact_address'] ?? '',
        country : json['country'] ?? '',
        countryIso : json['country_iso'] ?? '',
        date : json['date'] ?? '',
        designation : json['designation'] ?? '',
        email1 : json['email1'] ?? '',
        email2 : json['email2'] ?? '',
        email3 : json['email3'] ?? '',
        email4 : json['email4'] ?? '',
        emailVerified : json['email_verified'] ?? '',
        fax1 : json['fax1'] ?? '',
        fax2 : json['fax2'] ?? '',
        fcpFlag : json['fcp_flag'] ,
        firstName: json['first_name'] ?? '',
        fkGlLegalStatusId: json['fk_gl_legal_status_id'] ,
        fkGlusrBizIds: json['fk_glusr_biz_ids'] ?? '',
        fkGlusrNoofEmpId: json['fk_glusr_noof_emp_id'] ?? '',
        fkGlusrTurnoverId: json['fk_glusr_turnover_id'] ?? '',
        fkGlusrUsrPbizId: json['fk_glusr_usr_pbiz_id'] ?? '',
        freeshowroomAliasIm: json['freeshowroom_alias_im'] ?? '',
        glid: json['glid'] ?? '',
        glusrDisabledReason: json['glusr_disabled_reason'] ?? '',
        glusrListingStatusReason: json['glusr_listing_status_reason'] ?? '',
        glusrUsrAltMobileCountry: json['glusr_usr_alt_mobile_country'] ?? '',
        glusrUsrApprov: json['glusr_usr_approv'] ?? '',
        glusrUsrCompanyDesc: json['glusr_usr_company_desc'] ?? '',
        glusrUsrCusttypeId: json['glusr_usr_custtype_id'],
        glusrUsrCusttypeName: json['glusr_usr_custtype_name'] ?? '',
        glusrUsrCusttypeWeight: json['glusr_usr_custtype_weight'],
        glusrUsrDistrict: json['glusr_usr_district'] ?? '',
        glusrUsrFax2Area: json['glusr_usr_fax2_area'] ?? '',
        glusrUsrFax2Country: json['glusr_usr_fax2_country'] ?? '',
        glusrUsrFax2Number: json['glusr_usr_fax2_number'] ?? '',
        glusrUsrFaxArea: json['glusr_usr_fax_area'] ?? '',
        glusrUsrFaxCountry: json['glusr_usr_fax_country'] ?? '',
        glusrUsrFaxNumber: json['glusr_usr_fax_number'] ?? '',
        glusrUsrLatitude: json['glusr_usr_latitude'] ,
        glusrUsrListingStatus: json['glusr_usr_listing_status'] ?? '',
        glusrUsrLongitude: json['glusr_usr_longitude'] ,
        glusrUsrMembersince: json['glusr_usr_membersince'],
        glusrUsrMobileCountry: json['glusr_usr_mobile_country'] ?? '',
        glusrUsrPh2Area: json['glusr_usr_ph2_area'] ?? '',
        glusrUsrPh2Country: json['glusr_usr_ph2_country'] ?? '',
        glusrUsrPh2Number: json['glusr_usr_ph2_number'] ?? '',
        glusrUsrPhArea: json['glusr_usr_ph_area'] ?? '',
        glusrUsrPhCountry: json['glusr_usr_ph_country'] ?? '',
        glusrUsrPhMobile: json['glusr_usr_ph_mobile'] ?? '',
        glusrUsrPhMobileAlt: json['glusr_usr_ph_mobile_alt'] ?? '',
        glusrUsrPhNumber: json['glusr_usr_ph_number'] ?? '',
        glusrUsrSellinterest: json['glusr_usr_sellinterest'] ?? '',
        glusrUsrYearOfEstb: json['glusr_usr_year_of_estb'] ?? '',
        iilPerfEncryptGlusid: json['iil_perf_encrypt_glusid'] ?? '',
        image: json['image'] ?? '',
        imageStatus: json['image_status'] ?? '',
        isCatalog: json['is_catalog'],
        isPaid: json['is_paid'] ?? '',
        landmark: json['landmark'] ?? '',
        lastName: json['last_name'] ?? '',
        locality: json['locality'] ?? '',
        locationPreference: json['location_preference'] ,
        locationSetby: json['location_setby'] ?? '',
        locationSetdate: json['location_setdate'] ?? '',
        locationUpdateddate: json['location_updateddate'] ?? '',
        mobile1: json['mobile1'] ?? '',
        mobile2: json['mobile2'] ?? '',
        mobile3: json['mobile3'] ?? '',
        mobile4: json['mobile4'] ?? '',
        mobileVerified: json['mobile_verified'] ?? '',
        paidurl: json['paidurl'] ?? '',
        pnsNo: json['pns_no'] ?? '',
        pnsRatio: json['pns_ratio'] ?? '',
        salute: json['salute'] ?? '',
        showPscFlag: json['show_psc_flag'] ?? '',
        state: json['state'] ?? '',
        stateId: json['stateid'],
        telephone1: json['telephone1'] ?? '',
        telephone2: json['telephone2'] ?? '',
        telephone3: json['telephone3'] ?? '',
        telephone4: json['telephone4'] ?? '',
        turnover: json['turnover'] ?? '',
        uniqueId: json['unique_id'] ?? '',
        verifiedBusinessBuyerFlag: json['verified_business_buyer_flag'] ,
        website: json['website'] ?? '',
        zip: json['zip'] ?? '',);
    
  }
}
