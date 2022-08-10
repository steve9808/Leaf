package com.spring.leaf.archive.controller;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.jcraft.jsch.Channel;
import com.jcraft.jsch.ChannelSftp;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.JSchException;
import com.jcraft.jsch.Session;
import com.spring.leaf.archive.command.ArchiveFileVO;
import com.spring.leaf.archive.command.ArchiveVO;
import com.spring.leaf.archive.service.IArchiveService;
import com.spring.leaf.user.controller.UserController;


//data 컨트롤러 : 2022-08-01 생성

@Controller
@RequestMapping("/archive")
public class Archivecontroller {

	// 로그 출력을 위한 Logger 객체 생성
	private static final Logger logger = LoggerFactory.getLogger(Archivecontroller.class);
		
	//자료실 서비스 연결
	@Autowired
	private IArchiveService service;
	
	
	//자료실 목록 페이지로 이동 요청
	@GetMapping("/archiveList")
	public String archiveList(Model model) {
		
		model.addAttribute("archiveList", service.archiveList());
		
		return "/board/archive_list";
	}
	
	//글쓰기 페이지로 이동 요청
	@GetMapping("/archiveWrite")
	public String archiveWrite() {
		return "/board/archive_write";
	}
	
	//글쓰기 요청
	@PostMapping("/archiveContent/{archiveNo}")
	public String archiveContent(@PathVariable int archiveNo, Model model) {
		
		model.addAttribute("archive", service.archiveContent(archiveNo));
		
		return "board/archive_content";
	}
	
	//글 수정 페이지 이동
	@GetMapping("/archiveModify")
	public String archiveModify(@RequestParam("archiveNo") int archiveNo, Model model) {
		
		model.addAttribute("archive", service.archiveContent(archiveNo));
		
		return "board/archive_modify";
	}
	
	//글 수정 처리
	@PostMapping("/archiveUpdate")
	public String archiveUpdate(ArchiveVO vo, RedirectAttributes ra) {
		
		service.archiveModify(vo);
		ra.addFlashAttribute("msg", "updateSuccess");
		return "redirect:/board/archiveContent/" + vo.getArchiveNo();
	}
	
	//글 삭제 처리
	@PostMapping("/archiveDelete")
	public String archiveDelete(ArchiveVO vo, RedirectAttributes ra) {
		
		service.archiveDelete(vo.getArchiveNo());
		ra.addFlashAttribute("msg", "deleteSuccess");
		return "redirect:/board/archiveList";
	}
	
	//자료실 글번호 끌어오기
	@PostMapping("/archiveNoGet")
	@ResponseBody
	public int archiveNoGet() {
		return service.archiveNoGet();
	}
	
	//자료실파일 등록 요청
	@PostMapping("/archiveFile/{archiveNo}")
	@ResponseBody
	public String archiveFile(@RequestParam("archiveFile") MultipartFile archiveFile, @PathVariable("archiveNo") int archiveNo) throws Exception {
		logger.info("/archive/archiveFile : POST (자료실파일 등록 요청)");
		
		//날짜별로 폴더를 생성해서 파일을 관리한다.
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
		
		Date date = new Date();
		
		String location = sdf.format(date);
		
		//저장할 폴더 경로
		String uploadPath = "C:\\archiveFile\\" + location;
		
		File folder = new File(uploadPath);
		
		//폴더가 존재하지 않는다면 생성해라
		if(!folder.exists()) {
			folder.mkdirs();
		}
		
		//파일명을 고유한 랜덤 문자로 생성
		UUID uuid = UUID.randomUUID();
		//랜덤으로 생성된 문자에 있는 -을 모두 지운다.
		String uuids = uuid.toString().replaceAll("-", "");
		
		//사용자가 원래 가지고 있던 원본 파일명
		String realname = archiveFile.getOriginalFilename();
		//확장자 추출
		String extention = realname.substring(realname.indexOf("."), realname.length());
		
		//고유한 문자와 확장자를 합쳐 새로운 랜덤이름의 파일을 만들어주기
		String name = uuids + extention;
		
		//업로드한 파일을 서버 컴퓨터 내의 지정한 경로로 실제 저장
		File saveFile = new File(uploadPath + "\\" + name);
		
		try {
			archiveFile.transferTo(saveFile);
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		//받은 파일의 정보를 ArchiveFileVO 안에 넣고 데이터베이스에 저장한다.
		ArchiveFileVO vo = new ArchiveFileVO();
		vo.setArchiveFileFilename(name);
		vo.setArchiveFileUploadpath(uploadPath);
		vo.setArchiveFileRealname(realname);
		vo.setArchiveNo(archiveNo);
		
		service.archiveFile(vo);
		
		//파일을 로컬이 아닌 서버에도 저장한다.
		// SSH 원격접속을 위한 username, ip, port, password
		String username = "leaf";
		String host = "35.203.164.40";
		int port = 22;
		String password = "1q2w3e4r";

		Session session = null;
		Channel channel = null;
		
		try {
			// 파일을 원격서버로 보내기 위해 JSch 객체를 선언한다. (SFTP)
			JSch jsch = new JSch();

			// 세션 객체 생성 (JSch를 이용해 서버에 원격접속을 하기 위해서)
			session = jsch.getSession(username, host, port);
			session.setPassword(password);

			// ssh_config에 호스트 key 없이 접속이 가능하도록 property 설정
			java.util.Properties config = new java.util.Properties();
			config.put("StrictHostKeyChecking", "no");
			session.setConfig(config);

			// 접속 시도
			session.connect();

			// SFTP 채널 오픈 및 연결
			channel = session.openChannel("sftp");

			// SFTP 접속 시도
			channel.connect();

			// 로컬에 저장된 파일과 동일한 파일을 서버 /home/leaf/project 디렉토리 경로로 보낸다.
			// 앞에는 로컬에서 보낼 파일, 뒤에는 서버에서 받을 디렉토리 위치 경로
			ChannelSftp channelSftp = (ChannelSftp) channel;
			channelSftp.put(uploadPath + "\\" + name, "/home/leaf/archiveFile");

			// 이건 다운로드, 나중에 프로필사진 불러오기 할 때 참고해서
			// 사용하자!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			// 앞에는 서버에서 받아올 파일, 뒤에는 로컬에서 받을 폴더 위치 경로
			// channelSftp.get("/home/leaf/userProfile/" + name, uploadPath + "\\");

		} catch (JSchException e) {
			e.printStackTrace();
		} finally {
			// 전송이 완료되면 접속 종료
			if (channel != null) {
				channel.disconnect();
			}

			// 전송이 완료되면 접속 종료
			if (session != null) {
				session.disconnect();
			}
		}		
		
		
		return "YesArchiveFile";
		
	}
		
		//자료실 첨부파일 다운로드 요청
		@GetMapping("/archiveFile/download")
		public void archiveFileDownload(@RequestParam("archiveNo") int archiveNo, HttpServletRequest request, HttpServletResponse response) throws Exception {
			logger.info("/archive/archiveFile/download : GET (자료실 첨부파일 다운로드 요청)");
			
			//PrintWriter객체를 사용해 알림창을 띄울 때 한글깨짐을 방지하는 부분
			response.setContentType("text/html; charset=UTF=8");
			
			ArchiveFileVO vo = service.archiveFileGet(archiveNo);
			
			//사용자가 등록한 자료실 첨부파일이 없다면
			if(vo == null || vo.getArchiveFileFilename() == null) {
				// class 파일에서 자바스크립트 경고창을 띄우기 위한 PrintWriter 사용
				PrintWriter writer = response.getWriter();
				writer.print("<script>" + "alert('해당 글에는 첨부한 자료실 파일이 없습니다.');" + "location.replace('/');" + "</script>");
				writer.flush();
				writer.close();
			} else {
				File archiveFile = new File(vo.getArchiveFileUploadpath() + "\\" + vo.getArchiveFileFilename());
				
				if(!archiveFile.exists()) {
					
					File folder = new File(vo.getArchiveFileUploadpath());
					
					if(!folder.exists()) {
						folder.mkdirs();
					}
					
					// 파일을 서버에서 다운로드 받아 로컬에도 저장한다.
					// SSH 원격접속을 위한 계정 정보 및 주소 정보
					String username = "leaf";
					String host = "35.203.164.40";
					int port = 22;
					String password = "1q2w3e4r";

					Session session = null;
					Channel channel = null;

					try {
						// 파일을 원격서버로 보내기 위해 JSch 객체를 선언한다. (SFTP)
						JSch jsch = new JSch();

						// 세션 객체 생성 (JSch를 이용해 서버에 원격접속을 하기 위해서)
						session = jsch.getSession(username, host, port);
						session.setPassword(password);

						// ssh_config에 호스트 key 없이 접속이 가능하도록 property 설정 (이건 잘 모르겠다,. 따로 공부해야 할 듯)
						java.util.Properties config = new java.util.Properties();
						config.put("StrictHostKeyChecking", "no");
						session.setConfig(config);

						// 접속 시도
						session.connect();

						// SFTP 채널 오픈 및 연결
						channel = session.openChannel("sftp");

						// SFTP 접속 시도
						channel.connect();

						// 로컬에 저장된 파일과 동일한 파일을 서버 /home/leaf/project 디렉토리 경로로 보낸다.
						// 앞에는 로컬에서 보낼 파일, 뒤에는 서버에서 받을 디렉토리 위치 경로
						ChannelSftp channelSftp = (ChannelSftp) channel;

						// 앞에는 서버에서 받아올 파일, 뒤에는 로컬에서 받을 폴더 위치 경로
						channelSftp.get("/home/leaf/archiveFile/" + vo.getArchiveFileFilename(), vo.getArchiveFileUploadpath() + "\\");

					} catch (JSchException e) {
						e.printStackTrace();
					} finally {
						// 전송이 완료되면 접속 종료
						if (channel != null) {
							channel.disconnect();
						}

						// 전송이 완료되면 접속 종료
						if (session != null) {
							session.disconnect();
						}
					}
					
					//파일을 byte 배열로 변환한다.
					byte fileByte[] = FileUtils.readFileToByteArray(archiveFile);
					
					//파일 다운로드 응답 형식을 설정한다. 어플리케이션 파일이 리턴된다.
					response.setContentType("application/octet-stream");
					//파일 사이즈 지정
					response.setContentLengthLong(fileByte.length);

					// 다운로드 시 파일 원본 이름을 가져와서 원본이름을 적용시킨다.
					response.setHeader("Content-Disposition","attachment; fileName=\"" + URLEncoder.encode(vo.getArchiveFileRealname(), "UTF-8") + "\";");
					// application/octet-stream은 바이너리 데이터이므로 binary로 인코딩해준다.
					response.setHeader("Content-Transfer-Encoding", "binary");
					
					// 버퍼에 파일을 담아 스트림으로 출력한다.
					response.getOutputStream().write(fileByte);
					response.getOutputStream().flush();
					response.getOutputStream().close();

				} else {
					// 파일을 byte 배열로 변환한다.
					byte fileByte[] = FileUtils.readFileToByteArray(archiveFile);
					
					// 파일 다운로드 응답 형식을 설정한다. 어플리케이션  파일이 리턴된다.
					response.setContentType("application/octet-stream");
					// 파일 사이즈 지정
					response.setContentLength(fileByte.length);
					
					// 다운로드 시 파일 원본 이름을 가져와서 원본이름을 적용시킨다.
					response.setHeader("Content-Disposition","attachment; fileName=\"" + URLEncoder.encode(vo.getArchiveFileRealname(), "UTF-8") + "\";");
					// application/octet-stream은 바이너리 데이터이므로 binary로 인코딩해준다.
					response.setHeader("Content-Transfer-Encoding", "binary");
					
					// 버퍼에 파일을 담아 스트림으로 출력한다.
					response.getOutputStream().write(fileByte);
					response.getOutputStream().flush();
					response.getOutputStream().close();
				}
			}
		}
	}

	
	
	
	
	
	
	
	
	
