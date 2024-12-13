package context;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

public class WebRequestContext implements RequestContext{
    private Map _parameters;
    private HttpServletRequest _request;
    public WebRequestContext(){}
    
//    public String getCommandPath(){
//        String servletPath = _request.getServletPath();
//        String commandPath = servletPath.substring(1);
//
//        return commandPath;
//    }
    //テスト
    public String getCommandPath() {
        String commandPath = _request.getParameter("command"); // クエリパラメータから取得
        if (commandPath == null || commandPath.isEmpty()) {
            return "DefaultCommand"; // デフォルトコマンド 任意のやつ
        }
        return commandPath;
    }

    public String[] getParameter(String key){
        return (String[])_parameters.get(key);
    }
    public Object getRequest(){
        return _request;
    }
    public void setRequest(Object req){
        _request = (HttpServletRequest)req;

        _parameters = _request.getParameterMap();
    }
}
