package command;
import context.RequestContext;
import context.ResponseContext;

public abstract class AbstractCommand {
    private RequestContext reqContext;

    public void init(RequestContext reqc) {
        reqContext = reqc;
    }

    // 修正: スペルミスを直す
    public RequestContext getRequestContext() {
        return reqContext;
    }
    
    public abstract ResponseContext execute(ResponseContext resc);
}
