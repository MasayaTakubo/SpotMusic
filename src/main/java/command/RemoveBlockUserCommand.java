package command;

import context.RequestContext;
import context.ResponseContext;
import dao.BlockedUserDAO;

public class RemoveBlockUserCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String blockId = reqc.getParameter("blockId")[0];
        // データベースに保存
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        blockDAO.removeBlock(blockId);
        //List<blockBean> blocks = blockDAO.getBlock(userId);
        //resc.setResult(blocks);
        //resc.setTarget("blockList");
        resc.setTarget("login");
        return resc;
    }
}
