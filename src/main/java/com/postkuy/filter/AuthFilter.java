package com.postkuy.filter;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Inisialisasi filter jika diperlukan
        // Bisa digunakan untuk membaca konfigurasi filter dari web.xml jika ada
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        // Cast ServletRequest ke HttpServletRequest untuk mendapatkan session
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false); // Ambil session tanpa membuat session baru

        // Periksa apakah pengguna sudah login
        boolean isLoggedIn = (session != null && session.getAttribute("userId") != null);
        String loginURI = httpRequest.getContextPath() + "/login.jsp";
        String registerURI = httpRequest.getContextPath() + "/register.jsp";

        // URI yang diizinkan tanpa autentikasi (login, register, resources, dll.)
        String requestURI = httpRequest.getRequestURI();
        boolean isPublicResource = requestURI.startsWith(httpRequest.getContextPath() + "/css")
                || requestURI.startsWith(httpRequest.getContextPath() + "/js")
                || requestURI.startsWith(httpRequest.getContextPath() + "/img")
                || requestURI.equals(loginURI)
                || requestURI.equals(registerURI);

        // Jika pengguna tidak login dan halaman yang diminta bukan public resource, arahkan ke login
        if (!isLoggedIn && !isPublicResource) {
            httpResponse.sendRedirect(loginURI);
        } else {
            // Lanjutkan ke resource berikutnya jika sudah login atau halaman public
            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {
        // Cleanup jika diperlukan
        // Bisa digunakan untuk membersihkan resource yang diinisialisasi dalam `init`
    }
}
