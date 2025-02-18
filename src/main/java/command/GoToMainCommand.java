package command;

import context.ResponseContext;

public class GoToMainCommand extends AbstractCommand {

    @Override
    public ResponseContext execute(ResponseContext responseContext) {
        responseContext.setTarget("main"); // main.jsp に遷移
        return responseContext;
    }
}
