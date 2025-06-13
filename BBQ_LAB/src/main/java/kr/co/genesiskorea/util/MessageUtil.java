package kr.co.genesiskorea.util;

import java.io.PrintWriter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class MessageUtil {
	/**
	 * 자바스크립트 얼럿
	 *
	 * @param request
	 * @param response
	 * @param message
	 * @param forwardUrl
	 * @param target
	 * @throws Exception
	 */
	public static void showAlert(HttpServletRequest request, HttpServletResponse response, String message,
			String forwardUrl, String target) throws Exception {
		request.setAttribute("__sitemesh__decorator", "none");
		response.setCharacterEncoding("UTF-8");
		response.setContentType("text/html; charset=UTF-8");

		PrintWriter pw = response.getWriter();
		pw.println("<script type=\"text/javascript\">");

		if (StringUtil.isNotEmpty(message)) {
			pw.println("alert('" + StringUtil.replaceStr(message, "'", "\"") + "');");
		}

		if (forwardUrl == null || StringUtil.isEmpty(forwardUrl)) {
			pw.println("history.back();");
		} else {
			pw.println(((StringUtil.isNotEmpty(target)) ? target + "." : "") + "document.location.href='" + forwardUrl
					+ "';");
		}

		pw.println("</script>");
		pw.close();
	}

	/**
	 * 자바스크립트 얼럿 (alert & history.back)
	 *
	 * @param request
	 * @param response
	 * @param message
	 * @throws Exception
	 */
	public static void showAlert(HttpServletRequest request, HttpServletResponse response, String message)
			throws Exception {
		showAlert(request, response, message, null, null);
	}

	/**
	 * 자바스크립트 얼럿 (alert & forward)
	 *
	 * @param request
	 * @param response
	 * @param message
	 * @param forwardUrl
	 * @throws Exception
	 */
	public static void showAlert(HttpServletRequest request, HttpServletResponse response, String message,
			String forwardUrl) throws Exception {
		showAlert(request, response, message, forwardUrl, null);
	}

	/**
	 * 자바스크립트 얼럿 팝업용
	 *
	 * @param request
	 * @param response
	 * @param message
	 * @param forwardUrl
	 * @param openerForwardUrl
	 * @throws Exception
	 */
	public static void showAlertPop(HttpServletRequest request, HttpServletResponse response, String message,
			String forwardUrl, String openerForwardUrl) throws Exception {
		request.setAttribute("__sitemesh__decorator", "none");

		PrintWriter pw = response.getWriter();
		pw.println("<!DOCTYPE html><html lang=\"ko\"><head>");
		pw.println("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />");
		pw.println("<title></title>");
		pw.println("<script type=\"text/javascript\">");

		if (StringUtil.isNotEmpty(message))
			pw.println("alert('" + StringUtil.replaceStr(message, "'", "\"") + "');");

		if (StringUtil.isNotEmpty(openerForwardUrl)) {
			if (openerForwardUrl.equals("reload")) {
				pw.println("opener.location.reload();");
			} else {
				pw.println("opener.location.href='" + openerForwardUrl + "';");
			}
		}

		if (StringUtil.isNotEmpty(forwardUrl)) {
			pw.println("document.location.href='" + forwardUrl + "';");
		} else {
			pw.println("self.close();");
		}

		pw.println("</script>");
		pw.println("</head></html>");

		response.setContentType("text/html");
		pw.close();
	}

	/**
	 * 자바스크립트 얼럿 팝업 띄우기
	 *
	 * @param request
	 * @param response
	 * @param message
	 * @param popupName
	 * @param popupUrl
	 * @param documentForwardUrl
	 * @param openerForwardUrl
	 * @throws Exception
	 */
	public static void showAlertPopWindow(HttpServletRequest request, HttpServletResponse response, String message,
			String popupName, String popupUrl, String documentForwardUrl, String openerForwardUrl) throws Exception {
		request.setAttribute("__sitemesh__decorator", "none");

		PrintWriter pw = response.getWriter();
		pw.println("<!DOCTYPE html><html lang=\"ko\"><head>");
		pw.println("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />");
		pw.println("<title></title>");
		pw.println("<script type=\"text/javascript\">");

		if (StringUtil.isNotEmpty(message)) {
			pw.println("alert('" + StringUtil.replaceStr(message, "'", "\"") + "');");
		}

		if (StringUtil.isNotEmpty(openerForwardUrl)) {
			if (openerForwardUrl.equals("reload")) {

			} else {
				pw.println("opener.location.href='" + openerForwardUrl + "';");
			}
		}

		if (StringUtil.isNotEmpty(popupUrl)) {
			if (StringUtil.isEmpty(popupName)) {
				popupName = "popup";
			}
			pw.println("var popupNm = window.open('" + popupUrl + "',  '" + popupName + "', 'width=802, height=677')");

		}

		if (StringUtil.isNotEmpty(documentForwardUrl)) {
			pw.println("if (popupNm != null) { ");
			pw.println("document.location.href='" + documentForwardUrl + "';");
			pw.println("}");
		}

		pw.println("</script>");
		pw.println("</head></html>");

		response.setContentType("text/html");
		pw.close();
	}

	/**
	 * 자바스크립트 얼럿 팝업용 (alert & close)
	 *
	 * @param request
	 * @param response
	 * @param message
	 * @throws Exception
	 */
	public static void showAlertClose(HttpServletRequest request, HttpServletResponse response, String message)
			throws Exception {
		showAlertPop(request, response, message, null, null);
	}

	/**
	 * 자바스크립트 얼럿 팝업용 (alert & opener reload & close)
	 *
	 * @param request
	 * @param response
	 * @param message
	 * @throws Exception
	 */
	public static void showAlertCloseOpenerReload(HttpServletRequest request, HttpServletResponse response,
			String message) throws Exception {
		showAlertPop(request, response, message, null, "reload");
	}

	/**
	 * 자바스크립트 얼럿 팝업용 (alert & opener forward & close)
	 *
	 * @param request
	 * @param response
	 * @param message
	 * @param openerForwardUrl
	 * @throws Exception
	 */
	public static void showAlertCloseOpenerForward(HttpServletRequest request, HttpServletResponse response,
			String message, String openerForwardUrl) throws Exception {
		showAlertPop(request, response, message, null, openerForwardUrl);
	}

	public static void print(HttpServletResponse response, String msg) throws Exception {
		response.getWriter().print(msg);
	}

	public static void println(HttpServletResponse response, String msg) throws Exception {
		response.getWriter().println(msg);
	}
}
