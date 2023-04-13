package views;

import multichain.command.CommandElt;
import multichain.command.CommandManager;
import multichain.command.MultichainException;
import multichain.object.StreamKeyItem;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionListener;
import java.util.List;

public class Home extends JFrame {

    public static String host = "localhost";
    public static String port = "6274";
    public static String rpcuser = "multichainrpc";
    public static String rpcpasswd = "8y277ury1Rsw1Vbo8HLDP2mF94f4yMYTL3XLZ74Vpaxr";
    public static CommandManager commandManager;

    private static JPanel contentPanel;
    private static JButton btnRegistrarGraduando;
    private static JButton btnSubirCertificados;
    private static JButton btnVerCertificados;
    private static JLabel lblTitulo;

    public Home() {
        super("Titulos");
        initComponents();
    }

    public static void initComponents() {
        commandManager = new CommandManager(host, port, rpcuser, rpcpasswd);

        //construct components
        contentPanel = new JPanel();
        btnRegistrarGraduando = new JButton ("Registrar graduando");
        btnSubirCertificados = new JButton ("Subir certificado");
        btnVerCertificados = new JButton ("Ver certificados");
        lblTitulo = new JLabel ("BlockChain 'Titulos'");

        lblTitulo.setFont(new java.awt.Font("Segoe UI", 0, 18));
        //adjust size and set layout
        contentPanel.setPreferredSize (new Dimension(526, 222));
        contentPanel.setLayout (null);


        //set component bounds (only needed by Absolute Positioning)
        btnRegistrarGraduando.setBounds (30, 145, 155, 25);
        btnSubirCertificados.setBounds (200, 145, 135, 25);
        btnVerCertificados.setBounds (350, 145, 140, 25);
        lblTitulo.setBounds (190, 55, 200, 35);

        //actionslisteners
        btnRegistrarGraduando.addActionListener(evt -> {
            RegistrarGraduando frame1 = new RegistrarGraduando(commandManager);
            frame1.loadForm();
        });

        btnSubirCertificados.addActionListener(evt -> {
            SubirCertificado frame2 = new SubirCertificado(commandManager);
            frame2.loadForm();
        });

        btnVerCertificados.addActionListener(evt -> {
            VerCertificado frame3 = new VerCertificado(commandManager);
            frame3.loadForm();
        });

        //add components
        contentPanel.add (btnRegistrarGraduando);
        contentPanel.add (btnSubirCertificados);
        contentPanel.add (btnVerCertificados);
        contentPanel.add (lblTitulo);
    }

    public static void prueba() {
        List<StreamKeyItem> items;
        // Este programa imprime por consola la información de los datos almacenados en
        // un stream
        String stream = "Graduandos";
        try {
            commandManager.invoke(CommandElt.SUBSCRIBE, stream);
            items = (List<StreamKeyItem>) commandManager.invoke(CommandElt.LISTSTREAMITEMS, stream);

            for (StreamKeyItem item : items) {
                System.out.println(item);
            }
        } catch (
                MultichainException e) {
            e.printStackTrace();
        }
    }

    public void loadForm(){
        setContentPane(contentPanel);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        pack();
        setLocationRelativeTo(null);
        setVisible(true);
        setResizable(false);
    }
}
