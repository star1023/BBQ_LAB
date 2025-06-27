package kr.co.genesiskorea.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class SecurityUtil {
	public static String encryptSHA256(String str){

    	String sha = "";

    	try{
    		MessageDigest sh = MessageDigest.getInstance("SHA-256");
    		sh.update(str.getBytes()); 
    		byte byteData[] = sh.digest();
    		StringBuffer sb = new StringBuffer(); 
    		for(int i = 0 ; i < byteData.length ; i++){
    			sb.append(Integer.toString((byteData[i]&0xff) + 0x100, 16).substring(1));
    		}

    		sha = sb.toString();

    	}catch(NoSuchAlgorithmException e){
    		//e.printStackTrace();
    		System.out.println("Encrypt Error - NoSuchAlgorithmException");
    		sha = null;
    	}

    	return sha;
    }
	
	public static String getEncrypt(String pwd, String salt) {
        String result = "";
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update((pwd + salt).getBytes());
            byte[] pwdSalt = md.digest();

            StringBuffer sb = new StringBuffer();
            for(byte b : pwdSalt) {
                sb.append(String.format("%02x", b));
            }
            result = sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
        return result;
    }
}
