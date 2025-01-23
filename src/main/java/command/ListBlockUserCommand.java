package command;

import java.util.List;

import bean.blockBean;
import context.RequestContext;
import context.ResponseContext;
import dao.BlockedUserDAO;

public class ListBlockUserCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String userId = reqc.getParameter("userId")[0];
        // データベースに保存
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        List<blockBean> blocks = blockDAO.getBlockList(userId);
        resc.setResult(blocks);
        resc.setTarget("friendList");
        return resc;
    }
}
