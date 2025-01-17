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
//    public String getCommandPath() {
//        String commandPath = _request.getParameter("command"); // クエリパラメータから取得
//        if (commandPath == null || commandPath.isEmpty()) {
//            return "DefaultCommand"; // デフォルトコマンド 任意のやつ
//        }
//        return commandPath;
//    }
    
    // 1月17日排除
//    public String getCommandPath() {
//        // HttpServletRequest からリクエストURLを取得
//        String requestURL = _request.getRequestURL().toString();
//
//        // クエリパラメータ部分を抽出
//        int queryStartIndex = requestURL.indexOf("?");
//        if (queryStartIndex == -1) {
//            return "DefaultCommand"; // クエリパラメータがない場合はデフォルトコマンドを返す
//        }
//
//        // クエリパラメータ部分を切り出し
//        String queryString = requestURL.substring(queryStartIndex + 1);
//
//        // "command" パラメータの取得
//        String[] queryParams = queryString.split("&");
//        String commandPath = null;
//        
//        for (String param : queryParams) {
//            if (param.startsWith("command=")) {
//                commandPath = param.substring("command=".length());
//                break;
//            }
//        }
//
//        // "command" パラメータが見つからない場合はデフォルトコマンド
//        if (commandPath == null || commandPath.isEmpty()) {
//            return "DefaultCommand";
//        }
//
//        // "Command" が末尾に含まれていない場合は追加する
//        if (!commandPath.endsWith("Command")) {
//            commandPath += "Command";  // 末尾に "Command" を追加
//        }
//
//        return commandPath;
//    }
    public String getCommandPath() {
        // クエリパラメータ "command" を直接取得
        String commandPath = _request.getParameter("command");

        // "command" パラメータが見つからない場合はデフォルトコマンド
        if (commandPath == null || commandPath.isEmpty()) {
            return "DefaultCommand";
        }

        // "Command" が末尾に含まれていない場合は追加する
        if (!commandPath.endsWith("Command")) {
            commandPath += "Command";
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
