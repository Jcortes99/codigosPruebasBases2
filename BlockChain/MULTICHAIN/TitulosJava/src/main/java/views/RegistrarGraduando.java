package views;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.internal.LinkedTreeMap;
import multichain.command.CommandElt;
import multichain.command.CommandManager;
import multichain.command.MultichainException;

import javax.swing.*;
import java.awt.*;

public class RegistrarGraduando extends JFrame {

    public static CommandManager commandManager;

    private static JPanel contentPanel;
    private static JButton btnRegistrar;
    private static JLabel lblTitulo;
    private static JLabel lblNombre;
    private static JLabel lblApellidos;
    private static JTextField txtNombre;
    private static JTextField txtApellidos;
    private static JLabel lblFecha;
    private static JTextField txtFecha;
    private static JLabel lblCelular;
    private static JTextField txtCelular;
    private static JLabel lblPasaporte;
    private static JTextField txtPasaporte;

    public RegistrarGraduando(CommandManager _commandManager) {
        super("Registro de graduando");
        this.commandManager = _commandManager;
        initComponents();
    }

    private static void initComponents() {
        //construct components
        contentPanel = new JPanel();
        btnRegistrar = new JButton ("Registrar");
        lblTitulo = new JLabel ("Registrar graduando");
        lblNombre = new JLabel ("Nombre:");
        lblApellidos = new JLabel ("Apellidos:");
        txtNombre = new JTextField (20);
        txtApellidos = new JTextField (40);
        lblFecha = new JLabel ("Fecha de nacimiento");
        txtFecha = new JTextField (15);
        lblCelular = new JLabel ("Celular");
        txtCelular = new JTextField (15);
        lblPasaporte = new JLabel ("Pasaporte:");
        txtPasaporte = new JTextField (40);

        lblTitulo.setFont(new java.awt.Font("Segoe UI", 0, 18));
        //adjust size and set layout
        contentPanel.setPreferredSize (new Dimension (526, 299));
        contentPanel.setLayout (null);

        //add components
        contentPanel.add (btnRegistrar);
        contentPanel.add (lblTitulo);
        contentPanel.add (lblNombre);
        contentPanel.add (lblApellidos);
        contentPanel.add (txtNombre);
        contentPanel.add (txtApellidos);
        contentPanel.add (lblFecha);
        contentPanel.add (txtFecha);
        contentPanel.add (lblCelular);
        contentPanel.add (txtCelular);
        contentPanel.add (lblPasaporte);
        contentPanel.add (txtPasaporte);

        //set component bounds (only needed by Absolute Positioning)
        btnRegistrar.setBounds (175, 250, 155, 25);
        lblTitulo.setBounds (175, 10, 200, 35);
        lblNombre.setBounds (50, 110, 100, 25);
        lblApellidos.setBounds (275, 110, 100, 25);
        txtNombre.setBounds (45, 135, 190, 25);
        txtApellidos.setBounds (270, 135, 190, 25);
        lblFecha.setBounds (50, 170, 145, 25);
        txtFecha.setBounds (45, 200, 190, 25);
        lblCelular.setBounds (275, 170, 100, 25);
        txtCelular.setBounds (270, 200, 190, 25);
        lblPasaporte.setBounds (105, 65, 100, 25);
        txtPasaporte.setBounds (185, 65, 212, 30);

        // actionListener for the button
        btnRegistrar.addActionListener(evt -> {

            String pasaporte = txtPasaporte.getText();
            String nombre = txtNombre.getText();
            String apellidos = txtApellidos.getText();
            String fecha = txtFecha.getText();
            String celular = txtCelular.getText();

            try {
                // validation fields
                if (pasaporte.equals("") || nombre.equals("") || apellidos.equals("") || fecha.equals("") || celular.equals("")) {
                    throw new Exception("Llene todos los campos.");
                }

                LinkedTreeMap JSONin = new LinkedTreeMap();
                JSONin.put("nombre", nombre);
                JSONin.put("apellidos", apellidos);
                JSONin.put("fecha_nacimiento", fecha);
                JSONin.put("celular", celular);

                LinkedTreeMap JSONout = new LinkedTreeMap();
                JSONout.put("json", JSONin);

                Gson gson = new Gson();
                JsonObject JSONFULL = gson.toJsonTree(JSONout).getAsJsonObject();
                System.out.println(JSONFULL);

                Object Hash;
                Hash = commandManager.invoke(CommandElt.PUBLISH, "Graduandos", pasaporte, JSONFULL);
                JOptionPane.showMessageDialog(null, "Registrado correctamente \n Id de la transacción: "+ Hash.toString());

                txtPasaporte.setText("");
                txtNombre.setText("");
                txtApellidos.setText("");
                txtFecha.setText("");
                txtCelular.setText("");

            } catch (MultichainException e) {
                e.printStackTrace();
                throw new RuntimeException(e);
            } catch (Exception e) {
                JOptionPane.showMessageDialog(null, e.getMessage());
            }
        });
    }

    public void loadForm(){
        setContentPane(contentPanel);
        setDefaultCloseOperation(JFrame.HIDE_ON_CLOSE);
        pack();
        setLocationRelativeTo(null);
        setVisible(true);
        setResizable(false);
    }
}
