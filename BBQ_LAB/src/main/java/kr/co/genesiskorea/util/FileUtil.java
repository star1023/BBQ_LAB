package kr.co.genesiskorea.util;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.Metadata;

//import kr.co.aspn.vo.FileVO;

public class FileUtil {
	private static final Logger logger = LoggerFactory.getLogger(FileUtil.class);
	
	public static String upload(MultipartFile multipartFile, String path) throws Exception {
	    String fileName = null;
	     
	    try {
	      // 파일 정보
	      String originFilename = multipartFile.getOriginalFilename();
	      String extName = originFilename.substring(originFilename.lastIndexOf("."), originFilename.length()).toUpperCase();
	      Long size = multipartFile.getSize();
	      TimeUnit.MILLISECONDS.sleep(5);
	      // 서버에서 저장 할 파일 이름
	      String saveFileName = System.currentTimeMillis()+extName;
	       
	      System.err.println("originFilename : " + originFilename);
	      System.err.println("extensionName : " + extName);
	      System.err.println("size : " + size);
	      System.err.println("saveFileName : " + saveFileName);

	      String uploadPath = path + "/";
		  File dir = new File(uploadPath);
		  if (!dir.isDirectory()) {
			  dir.mkdirs();
		  }
		  File savefile = new File(uploadPath, saveFileName);
		  multipartFile.transferTo(savefile);
		  fileName = savefile.getName();
	    } catch (Exception e) {
	      throw new Exception(e);
	    }
	    return fileName;
	  }
	
	public static String upload2(MultipartFile multipartFile, String path,String tbType) throws Exception {
	    String fileName = null;
	     
	    Date now = new Date();
	    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	    String nowDate = sdf.format(now);
	    
	    try {
	      // 파일 정보
	      String saveFileName = multipartFile.getOriginalFilename();
//	      String extName = originFilename.substring(originFilename.lastIndexOf("."), originFilename.length()).toUpperCase();
	      Long size = multipartFile.getSize();
	      TimeUnit.MILLISECONDS.sleep(5);
	      // 서버에서 저장 할 파일 이름
//	      String saveFileName = System.currentTimeMillis()+extName;
//	       
//	      System.err.println("originFilename : " + originFilename);
//	      System.err.println("extensionName : " + extName);
//	      System.err.println("size : " + size);
//	      System.err.println("saveFileName : " + saveFileName);

	      String uploadPath = path + File.separator+tbType+File.separator+nowDate.substring(0, 7).replaceAll("-", "");
		  File dir = new File(uploadPath);
		  if (!dir.isDirectory()) {
			  dir.mkdirs();
		  }
		  File savefile = new File(uploadPath, saveFileName);
		  multipartFile.transferTo(savefile);
		  fileName = savefile.getName();
	    } catch (Exception e) {
	      throw new Exception(e);
	    }
	    return fileName;
	  }
	
	public static boolean fileDelete(String fileName, String path) {
		String uploadPath = path + "/";
		boolean result = true;
		String fileFullPath = uploadPath+fileName;
		
		File file = new File(fileFullPath);
		
		try {
			System.err.println("file.isFile :: "+file.isFile());

			if(file.isFile()){
				if (!file.delete()) {
					result = false;
				}	
			}			 
		} catch(Exception ex) {
			ex.printStackTrace();
			result = false;
		} finally {			
			file = null;
		}
		return result;
	}
	
	public static boolean UploadImageConfirm(String fileName, String path) {
		String uploadPath = path + "/";
		File file = new File(uploadPath, fileName);
	    try {
	    	if( file.exists() ) {
		        Metadata metadata = ImageMetadataReader.readMetadata(file);
		        return true;
	    	} else {
	    		return false;
	    	}
	    } catch (ImageProcessingException e) {
	        System.err.println("Product Image Upload Error1: " + e);
	        return false;
	    } catch (IOException e) {
            System.err.println("Product Image Upload Error2: " + e);
	        return false;
        }
	}
	
	/**
	 * 파일 내용 문자열로 반환
	 *
	 * @param fileName
	 * @return
	 */
	public static /* synchronized */ String read(String fileName) {
		return read(fileName, "UTF-8");
	}

	/**
	 * 파일 내용 문자열로 반환
	 *
	 * @param fileName
	 * @return
	 */
	public static /* synchronized */ String read(String fileName, String characterSet) {
		StringBuffer strBuf = new StringBuffer();
		boolean eof = false;
		try {
			BufferedReader bufReader = null;
			if (StringUtil.isEmpty(characterSet)) {
				FileReader file = new FileReader(fileName);
				bufReader = new BufferedReader(file);
			} else {
				bufReader = new BufferedReader(new InputStreamReader(new FileInputStream(fileName), characterSet));
			}
			while (!eof) {
				String line = bufReader.readLine();
				if (line == null)
					eof = true;
				else
					strBuf.append(line).append(System.getProperty("line.separator"));
			}
			bufReader.close();
		} catch (Exception localException) {
		}
		return strBuf.toString();
	}
	
	/**
	 * 파일 다운로드
	 * @param FileVO
	 * @param res
	 * @throws IOException
	 */
    /*
	public static void fileDownload(FileVO fileVO,HttpServletResponse res) throws IOException{
    	
		String path = fileVO.getPath() + File.separator +fileVO.getFileName();
		
		File file = new File(path);
		String fileName = fileVO.getFileName();
		String orgFileName = fileVO.getOrgFileName();
		res.reset();
		res.setContentType("application/x-msdownload;");
		res.setHeader("Content-Disposition", "attachment;filename=\"" + URLEncoder.encode(orgFileName, "UTF-8").replace("+", "%20") + "\";");
		
		OutputStream out = res.getOutputStream();
		FileInputStream fis = null;
		try{
			fis = new FileInputStream(file);
			FileCopyUtils.copy(fis, out);
		}finally{
			if(fis != null){
				try{
					fis.close();
				}catch(IOException ex){
					ex.printStackTrace();
				}
			}
			out.flush();
		}
    }
	   
	
   public static void fileDownload2(FileVO fileVO,HttpServletResponse res) throws IOException{
    	
		String path = fileVO.getPath() + File.separator +fileVO.getFileName();
		
		File file = new File(path);
		String fileName = fileVO.getFileName();
		res.reset();
		res.setContentType("application/x-msdownload;");
		res.setHeader("Content-Disposition", "attachment;filename=\"" + URLEncoder.encode(fileName, "UTF-8").replace("+", "%20") + "\";");
		
		OutputStream out = res.getOutputStream();
		FileInputStream fis = null;
		try{
			fis = new FileInputStream(file);
			FileCopyUtils.copy(fis, out);
		}finally{
			if(fis != null){
				try{
					fis.close();
				}catch(IOException ex){
					ex.printStackTrace();
				}
			}
			out.flush();
		}
   }
   */
   
   public static void fileDownload3(Map<String,String> fileInfo ,HttpServletResponse res) throws IOException{
   	
		String path = fileInfo.get("FILE_PATH") + File.separator +fileInfo.get("FILE_NAME");
		
		File file = new File(path);
		String fileName = fileInfo.get("ORG_FILE_NAME");
		res.reset();
		res.setContentType("application/x-msdownload;");
		res.setHeader("Content-Disposition", "attachment;filename=\"" + URLEncoder.encode(fileName, "UTF-8").replace("+", "%20") + "\";");
		
		OutputStream out = res.getOutputStream();
		FileInputStream fis = null;
		try{
			fis = new FileInputStream(file);
			FileCopyUtils.copy(fis, out);
		}finally{
			if(fis != null){
				try{
					fis.close();
				}catch(IOException ex){
					ex.printStackTrace();
				}
			}
			out.flush();
		}
  }
		   
   public static String upload(MultipartFile file, String path, String fileRename) throws Exception {

		String uploadedFileName;
		try {
			if (file == null || file.isEmpty()) {
				throw new NullPointerException("EMPTY FILE");
			}

			String uploadPath = path + "/";
			File dir = new File(uploadPath);
			if (!dir.isDirectory()) {
				dir.mkdirs();
			}

			String originalFileName = file.getOriginalFilename();
			if (StringUtil.isNotEmpty(originalFileName) && StringUtil.isNotEmpty(fileRename)) {
				originalFileName = changeFileName(originalFileName, fileRename);
			}
			File savefile = new File(uploadPath, originalFileName);
			file.transferTo(savefile);

			uploadedFileName = savefile.getName();
			logger.info("!upload success! filepath: {}, orgFileName: {}, uploadedFileName: {}", uploadPath,
					file.getOriginalFilename(), uploadedFileName);
		} catch (Exception e) {
			e.printStackTrace();
			throw e;
		}

		return uploadedFileName;
	}

	/**
	 * 파일 업로드
	 *
	 * @param file
	 * @param path
	 * @return
	 * @throws Exception
	 */
	public static String upload3(MultipartFile file, String path) throws Exception {
		String fileNameHeader = UUID.randomUUID().toString();
		return upload(file, path, fileNameHeader);
		
		//return upload(file, path, null);
	}
	
	/**
	 * 파일 업로드
	 *
	 * @param file
	 * @param path
	 * @return
	 * @throws Exception
	 */
	public static String upload3(MultipartFile file, String path, String fileIdx) throws Exception {
		String fileNameHeader = fileIdx;
		return upload(file, path, fileNameHeader);
		
		//return upload(file, path, null);
	}
	
	/**
	 * 파일명 변경
	 *
	 * @param orginFileName
	 * @param changeName
	 * @return
	 */
	public static String changeFileName(String orginFileName, String changeName) {

		//int index = orginFileName.lastIndexOf(".");
		//String fileExt = orginFileName.substring(index + 1);
		//String newName = changeName + "." + fileExt;
		String newName = changeName+"_"+orginFileName;
		return newName;
	}
	
	public static String getUUID() {
		return UUID.randomUUID().toString();
	}
	
	public static void multiFileDownload( List<String> sourceFiles, String zipFile_path, HttpServletResponse response ) {
		String zipFileName = getUUID()+".zip";
		String zipFile = zipFile_path+"/"+zipFileName;
		String downloadFileName = DateUtil.getDate(DateUtil.TYPE_DATE)+"_result";
		
		try{

		    // ZipOutputStream을 FileOutputStream 으로 감쌈
		    FileOutputStream fout = new FileOutputStream(zipFile);
		    ZipOutputStream zout = new ZipOutputStream(fout);

		    for(int i=0; i < sourceFiles.size(); i++){

		        //본래 파일명 유지, 경로제외 파일압축을 위해 new File로 
		        ZipEntry zipEntry = new ZipEntry(new File(sourceFiles.get(i)).getName());
		        zout.putNextEntry(zipEntry);

		        //경로포함 압축s
		        //zout.putNextEntry(new ZipEntry(sourceFiles.get(i)));

		        FileInputStream fin = new FileInputStream(sourceFiles.get(i));
		        byte[] buffer = new byte[1024];
		        int length;

		        // input file을 1024바이트로 읽음, zip stream에 읽은 바이트를 씀
		        while((length = fin.read(buffer)) > 0){
		            zout.write(buffer, 0, length);
		        }

		        zout.closeEntry();
		        fin.close();
		    }

		    zout.close();

		    response.setContentType("application/zip");
		    response.addHeader("Content-Disposition", "attachment; filename=" + downloadFileName + ".zip");

		    FileInputStream fis=new FileInputStream(zipFile);
		    BufferedInputStream bis=new BufferedInputStream(fis);
		    ServletOutputStream so=response.getOutputStream();
		    BufferedOutputStream bos=new BufferedOutputStream(so);

		    byte[] data=new byte[2048];
		    int input=0;

		    while((input=bis.read(data))!=-1){
		        bos.write(data,0,input);
		        bos.flush();
		    }

		    if(bos!=null) bos.close();
		    if(bis!=null) bis.close();
		    if(so!=null) so.close();
		    if(fis!=null) fis.close();

		} catch(IOException ioe){ 
			ioe.printStackTrace();
		} catch( Exception e ) {
			e.printStackTrace();
		} finally {
			fileDelete(zipFileName,zipFile_path);
		}
	}
	
	public static String getPdfContents( String path, String fileName) throws Exception {
		String content = "";
		try {
			File file = new File(path+File.separator+fileName);
			PDDocument document;
			document = PDDocument.load(file);
			
			PDFTextStripper s = new PDFTextStripper();
			String extractText = s.getText(document);
			//content = extractText.trim().replace(" ", "");
			content = extractText;
		} catch( Exception e ) {
			e.printStackTrace();	
		}
		return content;
	}
}
