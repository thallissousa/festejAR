//
//  ViewController.swift
//  ARApp
//
//  Created by Thallis Sousa on 02/06/22.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    let fogueirinhaImage = UIImage(named: "fogueirinha")
    let bandeirinhaImage = UIImage(named: "bandeirinha")
    let balaozinho = UIImage(named: "balaozinho")
    let balao = UIImage(named: "balao")
    let myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    @IBOutlet weak var howTo: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    
    //MARK: - Fazendo o botão com ação de tirar foto da tela
    @IBAction func takePhotoButton(_ sender: Any) {
        takePhotoButton.isHidden = true
        howTo.isHidden = true
        let haptickFeedback = UINotificationFeedbackGenerator()
                haptickFeedback.notificationOccurred(.success)
        
        let image = self.view.takeScreenshot()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        myLabel.textColor = .systemBackground
        myLabel.backgroundColor = .darkGray.withAlphaComponent(0.8)
        myLabel.layer.masksToBounds = true
        myLabel.layer.cornerRadius = 8
        myLabel.frame.size = CGSize(width: 70, height: 40)
        myLabel.center = CGPoint(x: view.center.x, y: view.center.y)
        myLabel.textAlignment = .center
        myLabel.text = "Salvo!"
        
        self.view.addSubview(myLabel)
        myLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.myLabel.isHidden = true
        }
        takePhotoButton.isHidden = false
        howTo.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        let fogueirinhaImageView = UIImageView(image: fogueirinhaImage)
        fogueirinhaImageView.frame = CGRect(x: 7,
                                            y: 650,
                                            width: 227/1.5,
                                            height: 191/1.5)
        
        let bandeirinhaImageView = UIImageView(image: bandeirinhaImage)
        bandeirinhaImageView.frame = CGRect(x: -0.03 ,
                                            y: -40,
                                            width: 647/1.5,
                                            height: 329/1.5)
        
        let balaozinhoImageView = UIImageView(image: balaozinho)
        balaozinhoImageView.frame = CGRect(x: view.center.x + 90,
                                           y: 450,
                                           width: 38*2,
                                           height: 77*2)
        
        let balaoImageView = UIImageView(image: balao)
        balaoImageView.frame = CGRect(x: view.center.x - 200,
                                      y: 20,
                                      width: 94*1.5,
                                      height: 115*1.5)
        
        guard ARFaceTrackingConfiguration.isSupported
        else {
            fatalError("Dispositivo não suportado.")
        }
        
        view.addSubview(fogueirinhaImageView)
        view.addSubview(bandeirinhaImageView)
        view.addSubview(balaozinhoImageView)
        view.addSubview(balaoImageView)
        view.addSubview(howTo)
    }
    
    @IBAction func howToButton(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "onboardingViewController") as? OnboardingViewController {
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARFaceTrackingConfiguration()
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    //MARK: - Renderizando a região do rosto com os nós
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let device = sceneView.device {
            let faceMeshGeometry = ARSCNFaceGeometry(device: device)
            let node = SCNNode(geometry: faceMeshGeometry)
            node.geometry?.firstMaterial?.fillMode = .lines
            node.geometry?.firstMaterial?.transparency = 0.0
            
            node.addChildNode(createHat())
            
            return node
            
        } else {
            fatalError("Nenhum dispositivo encontrado.")
        }
    }
    
    //MARK: - Dando update na função de renderização da AR
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
        }
    }
    
    //MARK: - Criando um nó com a imagem que será adicionada no AR
    func  createHat() -> SCNNode {
        //adicionar um node com imagem acima do node ja existe
        let hat = SCNNode(geometry: SCNPlane(width: 0.2,
                                             height: 0.1))
        hat.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "caipiraHat")
        hat.name = "Chapéu de caipira"
        hat.position = SCNVector3(x: 0.0,
                                  y: 0.13,
                                  z: 0.0)
        
        return hat
        
    }
}

//MARK: -  Extension de UIView para colocar as imagens estáticas dentro da cena
extension UIView {
    
    func takeScreenshot() -> UIImage {
        
        // Pega o contexto inicial da cena
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Desenha a view que está inserida nesse contexto
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // Pega a imagem
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Caso a imagem não seja nula, retorna a imagem (image!)
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}
