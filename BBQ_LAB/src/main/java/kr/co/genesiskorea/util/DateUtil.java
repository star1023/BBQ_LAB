package kr.co.genesiskorea.util;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class DateUtil {
	public static String TYPE_DATE = "yyyyMMdd";
	public static String TYPE_DATE_ = "yyyy-MM-dd";
	public static String TYPE_TIME = "HHmmss";
	public static String TYPE_DATETIME = "yyyyMMddHHmmss";
	public static String TYPE_YEAR = "yyyy";
	public static String TYPE_MONTH = "MM";
	public static String TYPE_DATE_HOUR = "yyyyMMddHH";
	public static String TYPE_DATE_HOUR_MIN = "yyyyMMddHHmm";

	public static int WARP_TYPE_YEAR = Calendar.YEAR;
	public static int WARP_TYPE_MONTH = Calendar.MONTH;
	public static int WARP_TYPE_DAY = Calendar.DATE;
	public static int WARP_TYPE_HOUR = Calendar.HOUR;
	public static int WARP_TYPE_MIN = Calendar.MINUTE;
	public static int WARP_TYPE_SEC = Calendar.SECOND;

	public static int WEEK_TYPE_SUNDAY = Calendar.SUNDAY;
	public static int WEEK_TYPE_MONDAY = Calendar.MONDAY;
	public static int WEEK_TYPE_TUESDAY = Calendar.TUESDAY;
	public static int WEEK_TYPE_WEDNESDAY = Calendar.WEDNESDAY;
	public static int WEEK_TYPE_THURSDAY = Calendar.THURSDAY;
	public static int WEEK_TYPE_FRIDAY = Calendar.FRIDAY;
	public static int WEEK_TYPE_SATURDAY = Calendar.SATURDAY;

	/**
	 *
	 * @param type
	 * @return
	 */
	public static String getDate(String type) {
		DateFormat df = new SimpleDateFormat(type);
		return df.format(Calendar.getInstance().getTime());
	}

	public static String getDateTime() {
		return getDate(TYPE_DATETIME);
	}

	public static String getDate() {
		return getDate(TYPE_DATE);
	}

	public static String getTime() {
		return getDate(TYPE_TIME);
	}

	/**
	 *
	 * @param type
	 * @param warpType
	 * @param value
	 * @return
	 */
	public static String getDateWarp(String type, int warpType, int value) {
		Calendar local = Calendar.getInstance();
		local.add(warpType, value);
		DateFormat df = new SimpleDateFormat(type);
		return df.format(local.getTime());
	}

	public static String getDateWarp(String date, String type, int warpType, int value) {
		Calendar local = Calendar.getInstance();
		try {
			local.setTime(new SimpleDateFormat(type).parse(date));
			local.add(warpType, value);
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		DateFormat df = new SimpleDateFormat(type);

		return df.format(local.getTime());
	}

	/**
	 * 
	 * 
	 */
	public static boolean isDayOfTheWeek(String date, int weekType) {
		Calendar local = Calendar.getInstance();
		local.set(Integer.parseInt(date.substring(0, 4)), Integer.parseInt(date.substring(4, 6)) - 1,
				Integer.parseInt(date.substring(6, 8)));
		// DateFormat df = new SimpleDateFormat(TYPE_DATE);

		if (weekType == local.get(Calendar.DAY_OF_WEEK)) {
			return true;
		} else {
			return false;
		}
	}

	public static int getDayOfTheWeek(String date) {
		Calendar local = Calendar.getInstance();
		local.set(Integer.parseInt(date.substring(0, 4)), Integer.parseInt(date.substring(4, 6)) - 1,
				Integer.parseInt(date.substring(6, 8)));

		return local.get(Calendar.DAY_OF_WEEK);
	}

	public static int intervalDate(String date1, String date2) {
		date1 = date1.substring(0, 8);
		date2 = date2.substring(0, 8);
		Calendar local1 = Calendar.getInstance();
		Calendar local2 = Calendar.getInstance();
		try {
			local1.setTime(new SimpleDateFormat(TYPE_DATE).parse(date1));
			local2.setTime(new SimpleDateFormat(TYPE_DATE).parse(date2));

		} catch (Exception e) {
			throw new RuntimeException(e);
		}

		return (int) ((local2.getTimeInMillis() - local1.getTimeInMillis()) / (24 * 60 * 60 * 1000));
	}

	public static Date parseDate(String date, String format) {
		try {
			SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
			return formatter.parse(date);
		} catch (ParseException ex) {
			throw new RuntimeException(ex);
		}
	}

	public static Date addDays(Date date, int day) {
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);
		calendar.add(Calendar.DATE, day);
		return calendar.getTime();
	}

	public static String getWeekOfTheDayStr(int week) {
		final String[] dayArray = { "占쎌?", "占쎌?", "占쎌?", "占쎈?", "筌?옙", "疫뀐옙", "占쎈?" };

		return dayArray[week - 1];
	}

	/**
	 * 
	 */
	public static Date addMonth(Date date, int month) {
		Calendar cal = Calendar.getInstance();
		cal.setTime(date);

		cal.add(Calendar.MONTH, month);

		return cal.getTime();
	}

	/**
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
	 * @param date
	 * @param dFormat
	 * @return
	 * @throws Exception
	 */
	public static String getDateFormat(Date date, String dFormat) throws Exception {
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);

		DateFormat df = new SimpleDateFormat(TYPE_DATETIME);
		String strDate = df.format(calendar.getTime());

		return getDateFormat(strDate, dFormat);
	}

	/**
	 *
	 * @param yearMonth
	 * @param minVal
	 * @return
	 */
	public static String getBeforeYearMonth(String yearMonth, int minVal) {

		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMM");
		Calendar cal = Calendar.getInstance();

		int year = Integer.parseInt(yearMonth.substring(0, 4));
		int month = Integer.parseInt(yearMonth.substring(4, 6));

		cal.set(year, month - minVal, 0);

		String beforeYear = dateFormat.format(cal.getTime()).substring(0, 4);
		String beforeMonth = dateFormat.format(cal.getTime()).substring(4, 6);
		String retStr = beforeYear + beforeMonth;

		return retStr;
	}

	/**
	 *
	 * @param day
	 * @param format
	 * @return
	 * @throws Exception
	 */
	public static String getToDayCalc(int day, String format) throws Exception {

		//Date date = Date.from(Instant.now());
		Calendar cal = Calendar.getInstance();
		Date date = cal.getTime();
		
		return getDateFormat(addDays(date, day), format);
	}

	/**
	 *
	 * @param year
	 * @param month
	 * @return
	 */
	public static String getLastMonthFirstDay(int year, int month) {
		if (month == 1) {
			year--;
			month = 13;
		}
		return year + "-" + StringUtil.n2c(month - 1) + "-" + "01";
	}

	/**
	 *
	 * @param year
	 * @param month
	 * @return
	 */
	public static String getNextMonthFisrtDay(int year, int month) {
		if (month == 12) {
			year++;
			month = 0;
		}
		return year + "-" + StringUtil.n2c(month + 1) + "-" + "01";
	}

	/**
	 *
	 * @param year
	 * @param month
	 * @return
	 */
	public static String getThisMonthFisrtDay(int year, int month) {

		return year + "-" + StringUtil.n2c(month) + "-" + "01";
	}
	
	/**
	 * 날짜 형식 변환
	 * @param dateString
	 * @param oldFormat
	 * @param newFormat
	 * @return
	 */
	public static String convertDate( String dateString, String oldFormat, String newFormat ) {
		try {
			if( dateString != null && !"".equals(dateString) && oldFormat != null && !"".equals(oldFormat)  && newFormat != null && !"".equals(newFormat)  ) {
				Date date = new SimpleDateFormat(oldFormat).parse(dateString);
				String newstring = new SimpleDateFormat(newFormat).format(date);
				return newstring;
			} else {
				return "";
			}
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return "";
		}
	}
}
