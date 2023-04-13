package views;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.internal.LinkedTreeMap;

import org.json.JSONArray;
import multichain.command.CommandElt;
import multichain.command.CommandManager;
import multichain.command.MultichainException;
import org.json.JSONObject;

import javax.swing.*;
import java.awt.*;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.Base64;

public class VerCertificado extends JFrame{
    public static CommandManager commandManager;

    private static JPanel contentPanel;
    private static JButton btnBuscar;
    private static JLabel lblTitulo;
    private static JLabel lblCodigo;
    private static JTextField txtPasaporte;
    private static JTextField txtCodigo;
    private static JLabel lblPasaporte;
    private static JButton btnAbrir;
    private static JLabel lblDiploma;
    private static JLabel lblNamefile;
    private static JLabel lblFecha;
    private static JTextField txtFecha;

    private static String encodingfile;

    public VerCertificado(CommandManager _commandManager) {
        super("Ver certificado");
        this.commandManager = _commandManager;
        initComponents();
    }

    private void initComponents() {
        //construct components
        contentPanel = new JPanel();
        btnBuscar = new JButton ("Buscar");
        lblTitulo = new JLabel ("Ver certificado");
        lblCodigo = new JLabel ("Código del programa: ");
        txtPasaporte = new JTextField (40);
        txtCodigo = new JTextField (40);
        lblPasaporte = new JLabel ("Pasaporte:");
        lblDiploma = new JLabel ("Diploma:");
        btnAbrir = new JButton ("Abrir");
        lblNamefile = new JLabel ("");
        lblFecha = new JLabel ("Fecha de expedición: ");
        txtFecha = new JTextField (20);

        txtFecha.setEditable(false);
        lblTitulo.setFont(new java.awt.Font("Segoe UI", 0, 18));
        //adjust size and set layout
        contentPanel.setPreferredSize (new Dimension(526, 243));
        contentPanel.setLayout (null);

        //add components
        contentPanel.add (btnBuscar);
        contentPanel.add (lblTitulo);
        contentPanel.add (lblCodigo);
        contentPanel.add (txtPasaporte);
        contentPanel.add (txtCodigo);
        contentPanel.add (lblPasaporte);
        contentPanel.add (lblDiploma);
        contentPanel.add (btnAbrir);
        contentPanel.add (lblNamefile);
        contentPanel.add (lblFecha);
        contentPanel.add (txtFecha);

        //set component bounds (only needed by Absolute Positioning)
        btnBuscar.setBounds (175, 195, 155, 25);
        lblTitulo.setBounds (195, 10, 250, 35);
        lblCodigo.setBounds (265, 55, 145, 25);
        txtPasaporte.setBounds (50, 90, 190, 25);
        txtCodigo.setBounds (265, 90, 190, 25);
        lblPasaporte.setBounds (50, 55, 100, 25);
        lblDiploma.setBounds (265, 120, 55, 25);
        btnAbrir.setBounds (265, 145, 190, 25);
        lblNamefile.setBounds (265, 170, 250, 25);
        lblFecha.setBounds (50, 120, 145, 25);
        txtFecha.setBounds (50, 145, 190, 25);

        //actionListener for FileChooser
        btnAbrir.addActionListener(evt -> {
            //validacion
            try {
                if (lblNamefile.getText().equals("")) {
                    throw new Exception("Aún no se ha encontrado ningún archivo");
                }
                File file = new File("../temp.pdf");
                if(!Desktop.isDesktopSupported()) {
                    throw new Exception("Archivo no soportado");
                }
                Desktop desktop = Desktop.getDesktop();
                if(file.exists())
                    desktop.open(file);

                lblNamefile.setText("");
            } catch (Exception e) {
                JOptionPane.showMessageDialog(null, e.getMessage());
            }
        });

        //actionListener for the botton Subir
        btnBuscar.addActionListener(evt -> {
            String pasaporte = txtPasaporte.getText();
            String codigo = txtCodigo.getText();
            ArrayList ResultList = new ArrayList();

            try {
                //Valida que haya al menos un campo
                if (pasaporte.equals("") && codigo.equals("")) {
                    throw new Exception("Llene al menos un campo.");
                }

                commandManager.invoke(CommandElt.SUBSCRIBE, "Certificados");
                commandManager.invoke(CommandElt.SETRUNTIMEPARAM, "maxshowndata", 131072);
                // Busca por pasaporte
                if (codigo.equals("")) {
                    ResultList = (ArrayList) commandManager.invoke(CommandElt.LISTSTREAMKEYITEMS, "Certificados", pasaporte);
                }

                // Busca por codigo
                else if (pasaporte.equals("")) {
                    ResultList = (ArrayList) commandManager.invoke(CommandElt.LISTSTREAMKEYITEMS, "Certificados", codigo);
                }

                // Busca por ambos
                else {
                    String[] key = {pasaporte, codigo};
                    LinkedTreeMap JSONin = new LinkedTreeMap();
                    JSONin.put("keys", key);

                    Gson gson = new Gson();
                    JsonObject JSONKeys = gson.toJsonTree(JSONin).getAsJsonObject();

                    ResultList = (ArrayList) commandManager.invoke(CommandElt.LISTSTREAMQUERYITEMS, "Certificados", JSONKeys);
                }

                if (ResultList.isEmpty()) {
                    throw new Exception("No existe.");
                }

                JSONArray jsonArray = new JSONArray(ResultList);
                System.out.println(jsonArray);
                JSONObject lastobject = jsonArray.getJSONObject(jsonArray.length()-1);
                JSONObject data = lastobject.getJSONObject("data").getJSONObject("json");

                String date = data.getString("fecha_expedicion");
                txtFecha.setText(date);

                this.encodingfile = data.getString("diploma");

                byte[] fileContent = Base64.getDecoder().decode(this.encodingfile);

                try (FileOutputStream fos = new FileOutputStream("../temp.pdf")) {
                    fos.write(fileContent);
                }

                lblNamefile.setText("Click on 'Abrir'");

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
