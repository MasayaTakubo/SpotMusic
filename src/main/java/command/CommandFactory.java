package command;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import context.RequestContext;

public abstract class CommandFactory {
    public static AbstractCommand getCommand(RequestContext rc) {
        AbstractCommand command = null;
        Properties prop = new Properties();

        try {
            // resources フォルダからプロパティファイルを読み込む
            InputStream input = CommandFactory.class.getClassLoader().getResourceAsStream("command.properties");
            if (input == null) {
                throw new RuntimeException("command.properties ファイルが見つかりません");
            }

            System.out.println("command.properties が見つかりました");
            prop.load(input);

            // rc.getCommandPath() の代わりにリクエストパラメータからコマンド名を取得
            String commandName = rc.getParameter("command")[0]; // 例: フォームの 'command' パラメータを利用
            if (commandName == null) {
                throw new RuntimeException("コマンド名が見つかりません: " + commandName);
            }

            String className = prop.getProperty(commandName);
            if (className == null) {
                throw new RuntimeException("コマンド名に対応するクラスが見つかりません: " + commandName);
            }

            // クラスが存在するか確認
            Class<?> c = Class.forName(className);
            command = (AbstractCommand) c.getDeclaredConstructor().newInstance();
        } catch (IOException e) {
            throw new RuntimeException("プロパティファイルの読み込みエラー: " + e.getMessage(), e);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("クラスが見つかりません: " + e.getMessage(), e);
        } catch (Exception e) {
            throw new RuntimeException("コマンドの取得エラー: " + e.getMessage(), e);
        }
        return command;
    }
}
