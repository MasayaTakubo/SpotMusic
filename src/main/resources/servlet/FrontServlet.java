package servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class FrontServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {        // 获取命令参数，例如 AddMessageCommand, ListMessageCommand 等
        String command = request.getParameter("command");

        if (command != null) {
            switch (command) {
                case "AddMessageCommand":
                    new AddMessageCommand().execute(request, response);
                    break;
                case "ListMessageCommand":
                    new ListMessageCommand().execute(request, response);
                    break;
                case "UpdateMessageCommand":
                    new UpdateMessageCommand().execute(request, response);
                    break;
                case "RemoveMessageCommand":
                    new RemoveMessageCommand().execute(request, response);
                    break;
                default:
                    response.sendRedirect("error.jsp");
                    break;
            }
        } else {
            response.sendRedirect("main.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
