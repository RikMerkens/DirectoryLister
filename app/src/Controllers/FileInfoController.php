<?php

namespace App\Controllers;

use DI\Container;
use PHLAK\Config\Interfaces\ConfigInterface;
use Psr\Http\Message\ResponseInterface;
use Slim\Psr7\Request;
use Slim\Psr7\Response;
use SplFileInfo;
use Symfony\Contracts\Translation\TranslatorInterface;

class FileInfoController
{
    /** @var Container The application container */
    protected $container;

    /** @var ConfigInterface App configuration component */
    protected $config;

    /** @var TranslatorInterface Translator component */
    protected $translator;

    /**
     * Create a new FileInfoHandler object.
     *
     * @param \DI\Container                                      $container
     * @param \PHLAK\Config\Interfaces\ConfigInterface           $config
     * @param \Symfony\Contracts\Translation\TranslatorInterface $translator
     */
    public function __construct(
        Container $container,
        ConfigInterface $config,
        TranslatorInterface $translator
    ) {
        $this->container = $container;
        $this->config = $config;
        $this->translator = $translator;
    }

    /**
     * Invoke the FileInfoHandler.
     *
     * @param \Slim\Psr7\Request  $request
     * @param \Slim\Psr7\Response $response
     *
     * @return \Psr\Http\Message\ResponseInterface
     */
    public function __invoke(Request $request, Response $response): ResponseInterface
    {
        $path = $request->getQueryParams()['info'];

        $file = new SplFileInfo(
            realpath($this->container->get('base_path') . '/' . $path)
        );

        if (! $file->isFile()) {
            return $response->withStatus(404, $this->translator->trans('error.file_not_found'));
        }

        if ($file->getSize() >= $this->config->get('app.max_hash_size', 1000000000)) {
            return $response->withStatus(500, $this->translator->trans('error.file_size_exceeded'));
        }

        $response->getBody()->write(json_encode([
            'hashes' => [
                'md5' => hash('md5', file_get_contents($file->getPathname())),
                'sha1' => hash('sha1', file_get_contents($file->getPathname())),
                'sha256' => hash('sha256', file_get_contents($file->getPathname())),
            ]
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }
}