package kr.co.genesiskorea.util;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.StringTokenizer;
import java.util.regex.Pattern;

public class StringUtil {
	private static final DecimalFormat df = new DecimalFormat("#,###.####");

	/**
	 * null 체크
	 *
	 * @param str
	 * @return
	 */
	public static boolean isEmpty(String str) {
		return ((str == null) || (str.length() == 0));
	}
	/**
	 * null 체크
	 *
	 * @param str
	 * @return
	 */
	public static boolean isEmpty(Object str) {
		
		if(str == null) {
			return true;
		}
		
		return isEmpty(str.toString()) ;
	}
	
	/**
	 * 배열 null 체크
	 *
	 * @param arr
	 * @return
	 */
	public static boolean isEmpty(Object[] arr) {
		return (arr == null || arr.length == 0);
	}

	/**
	 * 배열 null 체크
	 *
	 * @param arr
	 * @return
	 */
	public static boolean isNotEmpty(Object[] arr) {
		return !isEmpty(arr);
	}

	/**
	 * 공백 포함 null 체크
	 *
	 * @param foo
	 * @return
	 */
	public static final boolean isEmptyTrimmed(String foo) {
		return ((foo == null) || (foo.trim().length() == 0));
	}

	/**
	 * null이 아닌 값 체크
	 *
	 * @param str
	 * @return
	 */
	public static boolean isNotEmpty(String str) {
		return (!(isEmpty(str)));
	}

	/**
	 * replace 처리
	 *
	 * @param org
	 * @param var
	 * @param tgt
	 * @return
	 */
	public static String replaceStr(String org, String var, String tgt) {

		StringBuffer str = new StringBuffer("");
		int end = 0;
		int begin = 0;
		if (org == null || org.equals("")) {
			return org;
		}
		while (true) {
			end = org.indexOf(var, begin);
			if (end == -1) {
				end = org.length();
				str.append(org.substring(begin, end));
				break;
			}
			str.append(org.substring(begin, end) + tgt);
			begin = end + var.length();
		}

		return str.toString();
	}

	/**
	 * 문구 반대로
	 *
	 * @param str
	 * @return
	 */
	public static String reverse(String str) {
		if (str == null) {
			return null;
		}
		return new StringBuffer(str).reverse().toString();
	}

	/**
	 * 숫자형 문구 int형으로 변환
	 *
	 * @param str
	 * @param dValue
	 * @return
	 */
	public static int convInt(String str, int dValue) {
		int rValue = 0;
		try {
			rValue = Integer.parseInt(str);
		} catch (NumberFormatException e) {
			rValue = dValue;
		}

		return rValue;
	}

	/**
	 * 문자 말줄임 처리
	 *
	 * @param str
	 * @param length
	 * @return
	 */
	public static String cutStr(String str, int length) {
		try {
			String rValue = str.substring(0, length - 2);
			return rValue + "..";
		} catch (Exception e) {
		}
		return str;
	}

	/**
	 * 숫자에 세자리 수 콤마
	 *
	 * @param str
	 * @return
	 */
	public static String cvtNumber(String str) {
		String retStr;
		try {
			BigDecimal dcmData = new BigDecimal(str);
			retStr = df.format(dcmData);
		} catch (NumberFormatException nfe) {
			retStr = str;
		}

		return retStr;
	}

	/**
	 * 숫자 세자리수 콤마
	 *
	 * @param no
	 * @return
	 */
	public static String cvtNumber(int no) {
		return cvtNumber(no + "");
	}

	/**
	 * 문자 숫자형인지 체크
	 *
	 * @param str
	 * @return
	 */
	public static boolean isNumeric(String str) {
		if (str == null) {
			return false;
		}
		int sz = str.length();
		if (sz == 0) {
			return false;
		}
		for (int i = 0; i < sz; ++i) {
			if (!(Character.isDigit(str.charAt(i)))) {
				return false;
			}
		}
		return true;
	}

	/**
	 * 문자열 유무 검사
	 *
	 * @param str
	 * @param pattern
	 * @return
	 * @throws Exception
	 */
	public static boolean isPatternMatching(String str, String pattern) throws Exception {
		if (pattern.indexOf(42) >= 0) {
			pattern = pattern.replaceAll("\\*", ".*");
		}

		pattern = "^" + pattern + "$";

		return Pattern.matches(pattern, str);
	}

	/**
	 * 숫자 10보다 작은 건 01,02 형태로 표시
	 *
	 * @param num
	 * @return
	 */
	public static String n2c(int num) {
		if (num < 10) {
			return "0" + num;
		}
		return num + "";
	}

	/**
	 * 문자 10보다 작은건 01,02 형태로 표시
	 *
	 * @param snum
	 * @return
	 */
	public static String n2c(String snum) {
		int num = 0;
		try {
			num = Integer.parseInt(snum);
		} catch (Exception e) {
			return snum;
		}
		return n2c(num);
	}

	/**
	 * null 입력시 defValue 로 치환
	 *
	 * @param orgValue
	 * @param defValue
	 * @return
	 * @throws Exception
	 */
	public static String nvl(String orgValue, String defValue) throws Exception {
		String rtnStr = "";
		if (isEmpty(orgValue)) {
			rtnStr = defValue;
		} else {
			rtnStr = orgValue;
		}
		return rtnStr;
	}
	
	/**
	 * null 입력시 defValue 로 치환
	 *
	 * @param orgValue
	 * @param defValue
	 * @return
	 * @throws Exception
	 */
	public static String nvl(Object orgValue, String defValue) throws Exception {
		String rtnStr = "";
		if (isEmpty(orgValue)) {
			rtnStr = defValue;
		} else {
			rtnStr = ""+orgValue;
		}
		return rtnStr;
	}

	/**
	 * @param text
	 * @param parser
	 * @return
	 */
	public static String[] split(String text, String parser) {
		int count = 0, index = 0, i = 0, endIdx = 0;
		do {
			count++;
			index++;
			index = text.indexOf(parser, index);
		} while (index != -1);
		String[] data = new String[count];
		index = 0;
		while (i < count) {
			endIdx = text.indexOf(parser, index);
			if (endIdx == -1) {
				data[i] = text.substring(index).trim();
			} else {
				data[i] = text.substring(index, endIdx).trim();
			}
			index = endIdx + 1;
			i++;
		}
		return data;
	}

	/**
	 * 날짜 포맷 변경
	 *
	 * @param dFormat
	 * @param dt
	 * @return
	 * @throws Exception
	 */
	public static String getDateFormat(String dt, String dFormat) throws Exception {
		if (dt == null || (dt.length() != 8 && dt.length() != 14 && dt.length() != 12))
			return (dt);

		String y = dt.substring(0, 4);
		String m = dt.substring(4, 6);
		String d = dt.substring(6, 8);
		String h = "";
		String mm = "";
		String s = "";

		if (dt.length() == 14) {
			h = dt.substring(8, 10);
			mm = dt.substring(10, 12);
			s = dt.substring(12);
		}

		if (dt.length() == 12) {
			h = dt.substring(8, 10);
			mm = dt.substring(10, 12);
		}

		String rValue = "";
		for (int i = 0; i < dFormat.length(); i++) {
			switch (dFormat.charAt(i)) {
			case 'Y':
				rValue += y;
				break;
			case 'M':
				rValue += m;
				break;
			case 'D':
				rValue += d;
				break;
			case 'h':
				rValue += h;
				break;
			case 'm':
				rValue += mm;
				break;
			case 's':
				rValue += s;
				break;
			default:
				rValue += dFormat.charAt(i);
			}
		}
		return (rValue);
	}
	
	/**
	 * 
	 * @param day
	 * @param format
	 * @return
	 */
	public static String getDate(int day, String format) {
		String toDay = "";
		if( format != null && !"".equals(format)) {
			Calendar cal = Calendar.getInstance();
	        cal.add(Calendar.DATE , day);
	        
	        Date date = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat(format);

	        toDay = sdf.format(date);
		}
		
        return toDay;
	}

	/**
	 * 문자열 target을 주어진 길이(cutLength)만큼 잘라서, 말 줄임표 문자열(tail)을 붙인 뒤 반환
	 *
	 * @param target
	 * @param cutLength
	 * @param tail
	 * @return
	 */
	public static String cutStrLenNicely(String target, int cutLength, String tail) {
		String resultStr = target;
		if (resultStr.length() > cutLength) {
			resultStr = resultStr.substring(0, cutLength) + tail;
		}
		return resultStr;
	}

	/**
	 *
	 * 문자열을 짜르고 기준이 되는 값을 가져옴
	 *
	 * @param str
	 * @param gubun
	 * @param token
	 * @return
	 */
	public static String splitStr(String str, String gubun, int token) {

		StringTokenizer stk = new StringTokenizer(str, gubun);

		if (stk.countTokens() == 0) {
			return "";
		}

		String[] array = new String[stk.countTokens()];
		int i = 0;
		while (stk.hasMoreElements()) {
			array[i++] = stk.nextToken();
		}

		if (array.length > token) {
			return array[token];

		}

		return "";
	}

	/**
	 * replace
	 *
	 * @param str
	 * @param rep
	 * @param tok
	 * @return
	 */
	public static String replace(String str, String rep, String tok) {
		String retStr = "";
		if (isEmpty(str)) {
			return "";
		}

		int i = 0;
		for (int j = 0; (j = str.indexOf(rep, i)) > -1; i = j + rep.length()) {
			retStr = retStr + str.substring(i, j) + tok;
		}
		return retStr + str.substring(str.lastIndexOf(rep) + rep.length(), str.length());
	}
	
	public static String replaceAll(String str, String rep, String tok) {
		String retStr = "";
		if (isEmpty(str)) {
			return "";
		}

		/*int i = 0;
		for (int j = 0; (j = str.indexOf(rep, i)) > -1; i = j + rep.length()) {
			retStr = retStr + str.substring(i, j) + tok;
		}
		System.err.println("str : "+str);
		return retStr + str.substring(str.lastIndexOf(rep) + rep.length(), str.length());*/
		return str.replaceAll(rep, tok);
	}

	/**
	 * double 형 string으로 변환
	 *
	 * @param d
	 * @return
	 */
	public static String fmtDouble(double d) {

		if (d == (long) d) {
			return String.format("%d", (long) d);
		} else {
			return String.format("%s", d);
		}
	}

	/**
	 * 문자의 앞자리 제거
	 *
	 * @param str
	 * @param beginIndex
	 * @return
	 */
	public static String preSubStr(String str, int beginIndex) {
		if (isEmpty(str)) {
			return null;
		}
		return str.substring(beginIndex);
	}
	
	/**
	 * double 데이터의 지수형식을 제거한다.
	 * @param data
	 * @return
	 */
	public static String getDoubleToNumber( double data ) {
		//NumberFormat nf = NumberFormat.getInstance();
		//nf.setGroupingUsed(false);
		//System.err.println("format : data"+nf.format(data));
		//return nf.format(data);
		DecimalFormat df = new DecimalFormat("#.######################");
		String str = df.format(data);
		return str;
	}
	
	/**
	 * double 데이터의 지수형식을 제거한다.
	 * @param data
	 * @return
	 */
	public static String getDoubleToNumber( double data, int length ) {
		String formatter = "#";
		for( int i = 0 ; i < length ; i++ ) {
			if( i == 0 && length > 0) {
				formatter += ".";
			}
			formatter += "#";
		}
		DecimalFormat df = new DecimalFormat(formatter); 
		return df.format(data);
		/*NumberFormat nf = NumberFormat.getInstance();
		nf.setMinimumFractionDigits(0);//소수점 아래 최소 자리수
		nf.setMaximumFractionDigits(length);//소수점 아래 최대자리수
		return nf.format(data);*/
	}
	
	public static String getDoubleToNumber( String data, int length ) {
		try {
			String formatter = "#";
			for( int i = 0 ; i < length ; i++ ) {
				if( i == 0 && length > 0) {
					formatter += ".";
				}
				formatter += "#";
			}
			DecimalFormat df = new DecimalFormat(formatter); 
			return df.format(Double.parseDouble(data));
			/*NumberFormat nf = NumberFormat.getInstance();
			nf.setMinimumFractionDigits(0);//소수점 아래 최소 자리수
			nf.setMaximumFractionDigits(length);//소수점 아래 최대자리수
			return nf.format(Double.parseDouble(data));*/
		} catch(Exception e) {
			return "0";
		}
		
	}
	
	/**
	 * double 데이터의 지수형식을 제거한다.
	 * @param data
	 * @return
	 */
	public static String getDoubleToNumber( String data ) {
		try {
			NumberFormat nf = NumberFormat.getInstance();
			nf.setGroupingUsed(false);
			return nf.format(Double.parseDouble(data));
		} catch( Exception e ) {
			return "0";
		}

	}
	
	/**
	 * html 태크를 변환한다.
	 * @param str
	 * @return
	 */
	public static synchronized String getHtml(String str)
	{
		if(str == null || "".equals(str.trim()))
		{
			return "&nbsp;";
		} else
		{
			str = replace(str, "&", "&amp;");
			str = replace(str, "<", "&lt;");	//
			str = replace(str, ">", "&gt;");	//
			str = replace(str, "'", "&acute;");//
			str = replace(str, "\"", "&quot;");//
			str = replace(str, "|", "&brvbar;");
			str = replace(str, "\n", "<BR>");
			str = replace(str, "\r", "");
			//&plusmn; ±
			//&excl; !
			//# &num;
			//$	&dollar;
			//%	&percnt;
			//(	&lpar;
			//)	&rpar;
			//*	&ast; &midast;
			//+	&plus;
			//,	&comma;
			//.	&period;
			// /	&sol;
			// :	&colon;
			// ; 	&semi;
			// =	&equals;
			// ?	&quest;
			//@	&commat;
			//[	&lsqb; &lbrack;
			//]	&rsqb; &rbrack;
			//^	&Hat;
			//_	&lowbar;
			// {	&lcub; &lbrace;
			// }	&rcub; &rbrace;
			
			return str;
		}
	}
	
	/**
	 * html 태크를 변환한다.
	 * @param str
	 * @return
	 */
	public static synchronized String getHtmlBr(String str)
	{
		if(str == null || "".equals(str.trim()))
		{
			return "&nbsp;";
		} else
		{
			/*str = replace(str, "\n", "<BR>");
			str = replace(str, "\r", "");
			str = replace(str, "&amp;", "&");
			str = replace(str, "&lt;", "<");	//
			str = replace(str, "&gt;", ">");	//
			str = replace(str, "&acute;", "'");//
			str = replace(str, "&quot;", "\"");//
			str = replace(str, "&brvbar;", "|");
			str = replace(str, "&plusmn;", "±");
			str = replace(str, "&excl;", "!");
			str = replace(str, "&num;", "#");
			str = replace(str, "&dollar;", "$");
			str = replace(str, "&percnt;", "%");
			str = replace(str, "&lpar;", "(");
			str = replace(str, "&rpar;", ")");
			str = replace(str, "&ast;", "*");
			str = replace(str, "&midast;", "*");
			str = replace(str, "&plus;", "+");
			str = replace(str, "&comma;", ",");
			str = replace(str, "&period;", ".");
			str = replace(str, "&sol;", "/");
			str = replace(str, "&colon;", ":");
			str = replace(str, "&semi;", ";");
			str = replace(str, "&equals;", "=");
			str = replace(str, "&quest;", "?");
			str = replace(str, "&commat;", "@");
			str = replace(str, "&lsqb;", "[");
			str = replace(str, "&lbrack;", "[");
			str = replace(str, "&rsqb;", "]");
			str = replace(str, "&rbrack;", "]");
			str = replace(str, "&Hat;", "^");
			str = replace(str, "&lowbar;", "_");
			str = replace(str, "&lcub;", "");
			str = replace(str, "&lbrace;", "{");
			str = replace(str, "&rcub;", "}");
			str = replace(str, "&rbrace;", "}");
			str = replace(str, "&rarr;", "→");
			str = replace(str, "&darr;", "↓");
			str = replace(str, "&larr;", "←");
			str = replace(str, "&uarr;", "↑");*/
			
			str = replaceAll(str, "\n", "<BR>");
			str = replaceAll(str, "\r", "");
			str = replaceAll(str, "&amp;", "&");
			str = replaceAll(str, "&lt;", "<");	//
			str = replaceAll(str, "&gt;", ">");	//
			str = replaceAll(str, "&acute;", "'");//
			str = replaceAll(str, "&quot;", "\"");//
			str = replaceAll(str, "&brvbar;", "|");
			str = replaceAll(str, "&plusmn;", "±");
			str = replaceAll(str, "&excl;", "!");
			str = replaceAll(str, "&num;", "#");
			str = replaceAll(str, "&dollar;", "$");
			str = replaceAll(str, "&percnt;", "%");
			str = replaceAll(str, "&lpar;", "(");
			str = replaceAll(str, "&rpar;", ")");
			str = replaceAll(str, "&ast;", "*");
			str = replaceAll(str, "&midast;", "*");
			str = replaceAll(str, "&plus;", "+");
			str = replaceAll(str, "&comma;", ",");
			str = replaceAll(str, "&period;", ".");
			str = replaceAll(str, "&sol;", "/");
			str = replaceAll(str, "&colon;", ":");
			str = replaceAll(str, "&semi;", ";");
			str = replaceAll(str, "&equals;", "=");
			str = replaceAll(str, "&quest;", "?");
			str = replaceAll(str, "&commat;", "@");
			str = replaceAll(str, "&lsqb;", "[");
			str = replaceAll(str, "&lbrack;", "[");
			str = replaceAll(str, "&rsqb;", "]");
			str = replaceAll(str, "&rbrack;", "]");
			str = replaceAll(str, "&Hat;", "^");
			str = replaceAll(str, "&lowbar;", "_");
			str = replaceAll(str, "&lcub;", "");
			str = replaceAll(str, "&lbrace;", "{");
			str = replaceAll(str, "&rcub;", "}");
			str = replaceAll(str, "&rbrace;", "}");
			str = replaceAll(str, "&rarr;", "→");
			str = replaceAll(str, "&darr;", "↓");
			str = replaceAll(str, "&larr;", "←");
			str = replaceAll(str, "&uarr;", "↑");
			
			str = replaceAll(str, "&times;", "×");
			str = replaceAll(str, "&deg;", "°");
			
			return str;
		}
	}
	
	/**
	 * num앞에 0을 추가하여 length 자리수의 문자를 반환한다.
	 * @param num  숫자
	 * @param length 자리수
	 * @return
	 */
	public static synchronized String addZero(int num, int length)
	{
		String tempStr = ""+num;
		String zeroStr = "";
		for( int i = 0 ; i < length-tempStr.length() ; i++ ) {
			zeroStr+="0";
		}
		return zeroStr+tempStr;
	}
	
	/**
	 * @param str 원본 문자열
	 * @return 앞에 있는 0을 제거한 문자열 
	 */
	public static synchronized String delZero( String str ){ 
    	if(str==null || "".equals(str)) return "";    	
		String retStr = "";
		int index = 0;
		if( str.startsWith("0")) {
			StringBuffer sb = new StringBuffer();
			sb.append(str);
			for( int i  = 0 ; i < sb.length(); i++ ) {
				char c = sb.charAt(i);
				if( c != '0' ) {
					index = i;
					break;
				}
			}
			retStr = sb.toString().substring(index);
		} else {
			retStr = str;
		}
		return retStr;
	}
	
	
	public static synchronized double calPercent( double totalMixDivWeight, double mixDivWeight) {
		double result = 0;
		try {
			result = (mixDivWeight/totalMixDivWeight)*100;
		} catch( Exception e ) {
			result = 0;
		}
		return result;
	}
	
	public static synchronized double calPercentStepTow( double useRate, double calPercent, double totalUseRate ) {
		double result = 0;
		try {
			result = (useRate*calPercent)/totalUseRate;
		} catch( Exception e ) {
			result = 0;
		}
		return result;
	}
	
	/**
	 * html 태크를 변환한다.
	 * @param str
	 * @return
	 */
	public static synchronized String getOldFileName(String str)
	{
		if(str == null || "".equals(str.trim())) {
			return "";
		} else {
			String[] arr = str.split("\\\\");
			if( arr != null ) {
				return arr[arr.length-1];
			}
			return "";
		}
	}
	
	/**
	 * html 태크를 변환한다.
	 * @param str
	 * @return
	 */
	public static synchronized String getImagePath(String str)
	{
		if(str == null || "".equals(str.trim())) {
			return "";
		} else {
			String[] arr = str.split("/");
			if( arr != null ) {
				return arr[arr.length-1];
			}
			return "";
		}
	}
	
	/**
	 * devDoc 이미지 경로 반환
	 * @param str
	 * @return
	 */
	public static synchronized String getDevdocFileName(String str)
	{
		if(str == null || "".equals(str.trim())) {
			return "";
		} else {
			String[] arr = str.split("/");
			if( arr != null && arr.length > 2 ) {
				return arr[arr.length-2]+"/"+arr[arr.length-1];
			}
			return "";
		}
	}
	
	/**
	 * 시스템 이름.
	 * @param str
	 * @return
	 */
	public static synchronized String getSystemName()
	{
		return "PDM 시스템";
	} 
	
	/**
	 * 에러메세지
	 * @param e
	 * @param fromClass
	 * @return
	 */
	public static synchronized String getStackTrace(Exception e, Class fromClass){
    	StringBuffer sb = new StringBuffer();
    	StackTraceElement[] st =e.getStackTrace();
    	//발생 클래스 명
    	sb.append("[ Error from " + fromClass + " ]\r\n\r\n");
    	//메시지와 관련 클래스 명		
    	sb.append(e.toString());
    	//에러발생 클래스와 위치
    	for (StackTraceElement element : st) {
    		sb.append("\r\n\tat "+element.toString());
    	}
    	return sb.toString();
    }
	
	public static String addslashes(String str)	{
		String ret = "";
		if(str == null) {
			return "";
		}
		str = ret.replace("\'","\'\'");
		return str;
	}
	
	public static int roundData(String str){
		int result = 0;
		try{
			result = (int)Math.round(Double.parseDouble(str));
			return result;
		} catch (Exception e) {
			e.printStackTrace();
			return 0;
		}
	}
	
	public static double roundDuobleData(String str){
		try{
			double d = Math.round(Double.parseDouble(str)*1000);
			return d/1000;
		} catch (Exception e) {
			e.printStackTrace();
			return 0;
		}
	}
}
