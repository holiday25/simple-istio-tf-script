provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = "istio-system"

  create_namespace = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = "istio-system"

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = "istio-system"
  values     = [file("values-istio-ingress.yaml")]

  depends_on = [helm_release.istiod]
}

resource "kubernetes_namespace" "sample_app_ns" {
  metadata {
    name = "sample-app"
  }
}

resource "kubernetes_deployment" "httpd" {
  metadata {
    name      = "httpd"
    namespace = kubernetes_namespace.sample_app_ns.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "httpd"
      }
    }

    template {
      metadata {
        labels = {
          app = "httpd"
        }
      }

      spec {
        container {
          name  = "httpd"
          image = "httpd:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "httpd" {
  metadata {
    name      = "httpd"
    namespace = kubernetes_namespace.sample_app_ns.metadata[0].name
  }

  spec {
    selector = {
      app = "httpd"
    }

    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "httpd_ingress" {
  metadata {
    name      = "httpd-ingress"
    namespace = kubernetes_namespace.sample_app_ns.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "istio"
    }
  }

  spec {
    ingress_class_name = "istio"
    rule {
      http {
        path {
          path     = "/*"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.httpd.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
