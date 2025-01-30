package command;

import java.util.List;

import bean.blockBean;
import context.RequestContext;
import context.ResponseContext;
import dao.BlockedUserDAO;

public class AddBlockUserCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String blockedId = reqc.getParameter("blockedId")[0];
        String blockerId = reqc.getParameter("blockerId")[0];
        
        blockBean blockBean = new blockBean();
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        blockBean.setBlockerId(blockerId);
        blockBean.setBlockedId(blockedId);
        blockDAO.addBlock(blockBean);
        List<blockBean> blocks = blockDAO.getBlockList(blockerId);
        resc.setResult(blocks);
        resc.setTarget("blockList");
        return resc;
    }
}
