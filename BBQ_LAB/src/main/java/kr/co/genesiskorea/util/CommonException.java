package kr.co.genesiskorea.util;

public class CommonException extends RuntimeException {
	private static final long serialVersionUID = 1L;

	private String code;
	private String message;

	public CommonException() {
		this.code = "";
		this.message = "";
	}

	public CommonException(String message) {
		this();
		this.message = message;
	}

	public CommonException(String code, String message) {
		this.code = code;
		this.message = message;
	}

	public String getMessage() {
		return this.message;
	}

	public String getCode() {
		return this.code;
	}
}
